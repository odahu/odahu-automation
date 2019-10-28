resource "random_string" "name" {
  count       = 2
  length      = 20
  upper       = false
  lower       = true
  number      = true
  min_numeric = 5
  special     = false
}

locals {
  dockercfg = {
    "${azurerm_container_registry.legion.login_server}" = {
      email    = ""
      username = azurerm_container_registry.legion.admin_username
      password = azurerm_container_registry.legion.admin_password
    }
  }

  storage_tags = merge(
    { "purpose" = "Legion models storage" },
    var.tags
  )
  registry_tags = merge(
    { "purpose" = "Legion models images registry" },
    var.tags
  )

  model_docker_user        = azurerm_container_registry.legion.admin_username
  model_docker_password    = azurerm_container_registry.legion.admin_password
  model_docker_repo        = "${azurerm_container_registry.legion.login_server}/${var.cluster_name}"
  model_docker_web_ui_link = "https://${local.model_docker_repo}"

  sas_token_period         = "168h" # - 7 days # 8760h - 1 year

  allowed_nets             = concat(
    list(var.aks_subnet_cidr),
    list(var.service_cidr),
    list(data.azurerm_public_ip.aks_ext.ip_address),
    list(data.azurerm_public_ip.bastion.ip_address),
    split(", ", replace(join(", ", var.allowed_ips), "/32", ""))
  )
}

########################################################
# Azure Container Registry
########################################################
resource "azurerm_container_registry" "legion" {
  name                     = random_string.name[0].result
  resource_group_name      = var.resource_group
  location                 = var.location
  sku                      = "Standard"
  admin_enabled            = true

  tags                     = local.registry_tags

  # TODO: Add network restrictions (network_rule_set is only supported with the Premium SKU at this time)
  # 
  # network_rule_set {
  #   default_action = "Deny"
  #   ip_rule {
  #     action   = 
  #     ip_range = 
  #   }
  # }
}

data "azurerm_public_ip" "aks_ext" {
  name                = var.public_ip_name
  resource_group_name = var.resource_group
}

data "azurerm_public_ip" "bastion" {
  name                = "${var.cluster_name}-bastion"
  resource_group_name = var.resource_group
}

resource "null_resource" "secure_kube_api" {
  triggers = {
    build_number = timestamp()
  }

  provisioner "local-exec" {
    command = "az extension add --name aks-preview && az aks update --resource-group ${var.resource_group} --name ${var.cluster_name} --api-server-authorized-ip-ranges ${join(",", local.allowed_nets)}"
    interpreter = ["timeout", "300", "bash", "-c"]
  }
  provisioner "local-exec" {
    when    = "destroy"
    command = "az aks update --resource-group ${var.resource_group} --name ${var.cluster_name} --api-server-authorized-ip-ranges \"\""
    interpreter = ["timeout", "300", "bash", "-c"]
  }

}

########################################################
# Azure Blob container
########################################################
resource "azurerm_storage_account" "legion_data" {
  name                     = random_string.name[1].result
  resource_group_name      = var.resource_group
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  network_rules {
    default_action = "Allow"
    bypass         = [ "Logging", "Metrics", "AzureServices" ]
    ip_rules       = concat(
      # Removing /32 networks masks just in case
      # https://docs.microsoft.com/en-us/azure/storage/common/storage-network-security#grant-access-from-an-internet-ip-range
      split(", ", replace(join(", ", var.allowed_ips), "/32", "")),
      list(data.azurerm_public_ip.aks_ext.ip_address),
      list(data.azurerm_public_ip.bastion.ip_address)
    )
  }

  tags = local.storage_tags
}

data "azurerm_storage_account_sas" "legion" {
  connection_string = azurerm_storage_account.legion_data.primary_connection_string
  https_only        = true

  services {
    blob  = true
    queue = false
    table = false
    file  = false
  }

  resource_types {
    service   = false
    container = true
    object    = true
  }

  start  = formatdate("YYYY-MM-DD", timestamp())
  expiry = formatdate("YYYY-MM-DD", timeadd(timestamp(), local.sas_token_period))

  permissions {
    read    = true
    write   = true
    delete  = false
    list    = true
    add     = true
    create  = true
    update  = true
    process = false
  }
}

resource "azurerm_storage_container" "legion_bucket" {
  name                  = var.legion_data_bucket
  storage_account_name  = azurerm_storage_account.legion_data.name
  container_access_type = "private"
  metadata              = local.storage_tags
  depends_on            = [azurerm_storage_account.legion_data]
}
