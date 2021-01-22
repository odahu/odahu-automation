data "external" "egress_ip" {
  program = [
    "az", "network", "public-ip", "show",
    "--resource-group", var.resource_group,
    "--name", var.egress_ip_name,
    "-o", "json",
    "--query", "{id:id,ip_address:ipAddress}"
  ]
}

resource "local_file" "storage_class" {
  content = templatefile("${path.module}/templates/storage-class.tpl", {
    storage_class_name     = var.storage_class_name
    disk_encryption_set_id = azurerm_disk_encryption_set.this.id
  })
  filename = "/tmp/.odahu/azure_storage_class.yml"

  file_permission      = 0644
  directory_permission = 0755
}

locals {
  bastion_ip = length(var.bastion_ip) != 0 ? ["${var.bastion_ip}/32"] : []

  allowed_nets = concat(
    list(var.aks_subnet_cidr),
    list(var.service_cidr),
    list("${data.external.egress_ip.result.ip_address}/32"),
    local.bastion_ip,
    var.allowed_ips
  )

  default_node_pool = var.node_pools["main"]
  additional_node_pools = length(var.node_pools) > 1 ? {
    for key, value in var.node_pools : key => value if key != "main"
  } : map({})

  node_pools_spot_settings = length(var.node_pools) > 1 ? {
    for key, value in var.node_pools :
    key => tobool(lookup(value, "preemptible", false)) ? {
      labels          = { "kubernetes.azure.com/scalesetpriority" = "spot" }
      priority        = "Spot"
      eviction_policy = "Delete"
      spot_max_price  = 0.5
      } : {
      labels          = {}
      priority        = "Regular"
      eviction_policy = null
      spot_max_price  = null
    }
  } : map({})

  default_nodes_count  = "1"
  default_nodes_min    = "1"
  default_nodes_max    = "2"
  default_machine_type = "Standard_B2s"
  default_disk_size_gb = "32"
  default_pods_max     = "32"
}

########################################################
# Disk encryption set
########################################################

resource "azurerm_disk_encryption_set" "this" {
  name                = "${var.cluster_name}-encyption-set"
  resource_group_name = var.resource_group
  location            = var.location
  key_vault_key_id    = var.kms_key_id

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_key_vault_access_policy" "encrypt-disk" {
  key_vault_id = var.kms_vault_id

  tenant_id = azurerm_disk_encryption_set.this.identity.0.tenant_id
  object_id = azurerm_disk_encryption_set.this.identity.0.principal_id

  key_permissions = [
    "get",
    "unwrapKey",
    "wrapKey"
  ]
}

########################################################
# Deploy AKS cluster
########################################################

resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.cluster_name
  location            = var.location
  resource_group_name = var.resource_group
  # https://github.com/Azure/AKS/issues/3
  # There's additional resource group created, that used to represent and hold the lifecycle of 
  # k8s cluster resources. We only can set a name for it.
  node_resource_group    = "${var.resource_group}-k8s"
  kubernetes_version     = var.k8s_version
  disk_encryption_set_id = azurerm_disk_encryption_set.this.id

  private_cluster_enabled    = false
  enable_pod_security_policy = false
  dns_prefix                 = var.aks_dns_prefix

  linux_profile {
    admin_username = var.ssh_user
    ssh_key {
      key_data = var.ssh_public_key
    }
  }

  lifecycle {
    ignore_changes = [
      default_node_pool[0].node_count,
      default_node_pool[0].tags["created-on"],
      tags["created-on"]
    ]
  }

  default_node_pool {
    name            = "main"
    vm_size         = lookup(local.default_node_pool, "machine_type", local.default_machine_type)
    os_disk_size_gb = lookup(local.default_node_pool, "disk_size_gb", local.default_disk_size_gb)
    vnet_subnet_id  = var.aks_subnet_id

    type                  = "VirtualMachineScaleSets"
    enable_auto_scaling   = true
    enable_node_public_ip = false

    # In AKS there's no option to create node pool with 0 nodes, minimum is 1
    node_count = lookup(local.default_node_pool, "init_node_count", local.default_nodes_count)
    min_count  = lookup(local.default_node_pool, "min_node_count", local.default_nodes_min)
    max_count  = lookup(local.default_node_pool, "max_node_count", local.default_nodes_max)
    max_pods   = lookup(local.default_node_pool, "max_pods", local.default_pods_max)

    node_taints = [
      for taint in lookup(local.default_node_pool, "taints", []) :
      "${taint.key}=${taint.value}:${taint.effect}"
    ]

    node_labels = { "project" = "odahu-flow" }

    tags = var.aks_tags
  }

  # We have to provide Service Principal account credentials in order to create node resource group
  # and appropriate dynamic resources related to AKS (node resource groups, network security groups,
  # virtual machine scale sets, loadbalancers)
  service_principal {
    client_id     = var.sp_client_id
    client_secret = var.sp_secret
  }

  addon_profile {
    kube_dashboard {
      enabled = false
    }
    oms_agent {
      enabled                    = var.aks_analytics_workspace_id == "" ? false : true
      log_analytics_workspace_id = var.aks_analytics_workspace_id == "" ? null : var.aks_analytics_workspace_id
    }
  }

  auto_scaler_profile {
    balance_similar_node_groups      = false
    max_graceful_termination_sec     = 600
    scale_down_delay_after_add       = "10m"
    scale_down_delay_after_delete    = "10s"
    scale_down_delay_after_failure   = "3m"
    scale_down_unneeded              = "10m"
    scale_down_unready               = "20m"
    scale_down_utilization_threshold = 0.5
    scan_interval                    = "10s"
  }

  api_server_authorized_ip_ranges = local.allowed_nets

  role_based_access_control {
    enabled = true
  }

  network_profile {
    network_plugin    = "azure"
    network_policy    = "calico"
    load_balancer_sku = "standard"

    load_balancer_profile {
      outbound_ip_address_ids = [data.external.egress_ip.result.id]
    }
  }

  tags = var.aks_tags

  depends_on = [azurerm_disk_encryption_set.this]
}

resource "azurerm_kubernetes_cluster_node_pool" "aks" {
  for_each = local.additional_node_pools

  lifecycle {
    ignore_changes = [
      node_count,
      tags["created-on"]
    ]
  }

  enable_node_public_ip = false
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id

  # Pool name must start with a lowercase letter, have max length of 12, and only have characters a-z0-9
  name            = substr(replace(each.key, "/[-_]/", ""), 0, 12)
  vm_size         = lookup(each.value, "machine_type", local.default_machine_type)
  os_disk_size_gb = lookup(each.value, "disk_size_gb", local.default_disk_size_gb)
  os_type         = "Linux"
  vnet_subnet_id  = var.aks_subnet_id

  enable_auto_scaling = true

  priority        = local.node_pools_spot_settings[each.key].priority
  eviction_policy = local.node_pools_spot_settings[each.key].eviction_policy
  spot_max_price  = local.node_pools_spot_settings[each.key].spot_max_price

  node_count = lookup(each.value, "init_node_count", local.default_nodes_count)
  min_count  = lookup(each.value, "min_node_count", local.default_nodes_min)
  max_count  = lookup(each.value, "max_node_count", local.default_nodes_max)
  max_pods   = lookup(each.value, "max_pods", local.default_pods_max)

  node_taints = [
    for taint in lookup(each.value, "taints", []) : "${taint.key}=${taint.value}:${taint.effect}"
  ]

  node_labels = merge(
    { "project" = "odahu-flow" },
    { for key, value in lookup(each.value, "labels", {}) : key => value },
    local.node_pools_spot_settings[each.key].labels
  )

  tags = var.aks_tags
}

resource "null_resource" "bastion_kubeconfig" {
  count = var.bastion_enabled ? 1 : 0

  connection {
    host        = var.bastion_ip
    user        = "ubuntu"
    type        = "ssh"
    private_key = var.bastion_privkey
    timeout     = "1m"
    agent       = false
  }

  provisioner "remote-exec" {
    inline = [
      "printf \"${var.ssh_public_key}\" >> ~/.ssh/authorized_keys",
      "sudo wget -qO /usr/local/bin/kubectl \"https://storage.googleapis.com/kubernetes-release/release/v${var.k8s_version}/bin/linux/amd64/kubectl\"",
      "sudo chmod +x /usr/local/bin/kubectl",
      "mkdir -p ~/.kube && printf \"${azurerm_kubernetes_cluster.aks.kube_config_raw}\" > ~/.kube/config"
    ]
  }

  depends_on = [azurerm_kubernetes_cluster.aks]
}

# Setup kubectl
resource "null_resource" "setup_kubectl" {
  triggers = {
    build_number = timestamp()
  }
  provisioner "local-exec" {
    command = "bash -c 'az aks get-credentials --name ${var.cluster_name} --resource-group ${var.resource_group} --overwrite-existing'"
  }
  depends_on = [azurerm_kubernetes_cluster.aks]
}

resource "null_resource" "kube_api_check" {
  triggers = {
    build_number = timestamp()
  }

  provisioner "local-exec" {
    command = "timeout 1200 bash -c 'until curl -sk https://${azurerm_kubernetes_cluster.aks.fqdn}; do sleep 20; done'"
  }

  depends_on = [null_resource.setup_kubectl]
}

# Setup default encrypted storage class
resource "null_resource" "create_encrypted_storage_class" {
  provisioner "local-exec" {
    command = "timeout 90 bash -c 'until kubectl apply -f ${local_file.storage_class.filename}; do sleep 5; done'"
  }

  depends_on = [null_resource.kube_api_check]
}


resource "null_resource" "setup_storage_class" {
  provisioner "local-exec" {
    command = "bash ../../../../../scripts/set_default_storage_class.sh \"${var.storage_class_name}\""
  }
  depends_on = [null_resource.create_encrypted_storage_class]
}

