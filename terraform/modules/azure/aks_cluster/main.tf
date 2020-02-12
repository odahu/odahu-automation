data "external" "egress_ip" {
  program = [
    "az", "network", "public-ip", "show",
    "--resource-group", var.resource_group,
    "--name", var.egress_ip_name,
    "-o", "json",
    "--query", "{id:id,ip_address:ipAddress}"
  ]
}

locals {
  bastion_ip = var.bastion_enabled ? ["${var.bastion_ip}/32"] : []
  allowed_nets = concat(
    list(var.aks_subnet_cidr),
    list(var.service_cidr),
    list("${data.external.egress_ip.result.ip_address}/32"),
    local.bastion_ip,
    var.allowed_ips
  )
  default_node_pool     = var.node_pools["main"]
  additional_node_pools = length(var.node_pools) > 1 ? { for key, value in var.node_pools : key => value if key != "main" } : map({})
  default_nodes_count   = "1"
  default_nodes_min     = "1"
  default_nodes_max     = "2"
  default_machine_type  = "Standard_B2s"
  default_disk_size_gb  = "32"
  default_pods_max      = "64"
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
  node_resource_group = "${var.resource_group}-k8s"
  dns_prefix          = var.aks_dns_prefix
  kubernetes_version  = var.k8s_version

  linux_profile {
    admin_username = var.ssh_user
    ssh_key {
      key_data = var.ssh_public_key
    }
  }

  lifecycle {
    ignore_changes = [
      default_node_pool[0].node_count
    ]
  }

  default_node_pool {
    name            = "main"
    vm_size         = lookup(local.default_node_pool, "machine_type", local.default_machine_type)
    os_disk_size_gb = lookup(local.default_node_pool, "disk_size_gb", local.default_disk_size_gb)
    vnet_subnet_id  = var.aks_subnet_id

    type                = "VirtualMachineScaleSets"
    enable_auto_scaling = true

    # In AKS there's no option to create node pool with 0 nodes, minimum is 1
    node_count = lookup(local.default_node_pool, "init_node_count", local.default_nodes_count)
    min_count  = lookup(local.default_node_pool, "min_node_count", local.default_nodes_min)
    max_count  = lookup(local.default_node_pool, "max_node_count", local.default_nodes_max)
    max_pods   = lookup(local.default_node_pool, "max_pods", local.default_pods_max)

    node_taints = [
      for taint in lookup(local.default_node_pool, "taints", []) :
      "${taint.key}=${taint.value}:${taint.effect}"
    ]
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

  api_server_authorized_ip_ranges = local.allowed_nets

  role_based_access_control {
    enabled = true
  }

  network_profile {
    network_plugin    = "azure"
    network_policy    = "calico"
    load_balancer_sku = "standard"

    load_balancer_profile {
      outbound_ip_address_ids = [ data.external.egress_ip.result.id ]
    }
  }

  tags = var.aks_tags
}

resource "azurerm_kubernetes_cluster_node_pool" "aks" {
  for_each = local.additional_node_pools

  lifecycle {
    ignore_changes = [
      node_count
    ]
  }

  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id

  # Pool name must start with a lowercase letter, have max length of 12, and only have characters a-z0-9
  name            = substr(replace(each.key, "/[-_]/", ""), 0, 12)
  vm_size         = lookup(each.value, "machine_type", local.default_machine_type)
  os_disk_size_gb = lookup(each.value, "disk_size_gb", local.default_disk_size_gb)
  os_type         = "Linux"
  vnet_subnet_id  = var.aks_subnet_id

  enable_auto_scaling = true

  node_count = lookup(each.value, "init_node_count", local.default_nodes_count)
  min_count  = lookup(each.value, "min_node_count", local.default_nodes_min)
  max_count  = lookup(each.value, "max_node_count", local.default_nodes_max)
  max_pods   = lookup(each.value, "max_pods", local.default_pods_max)

  node_taints = [
    for taint in lookup(each.value, "taints", []) :
    "${taint.key}=${taint.value}:${taint.effect}"
  ]
}
