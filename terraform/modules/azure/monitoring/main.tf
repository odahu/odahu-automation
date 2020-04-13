# The WorkSpace name has to be unique across the whole of azure, not just the current subscription/tenant.
resource "random_id" "workspace" {
  count       = var.enabled ? 1 : 0
  byte_length = 8
}

resource "azurerm_log_analytics_workspace" "k8s" {
  count               = var.enabled ? 1 : 0
  name                = "${var.cluster_name}-${random_id.workspace[0].dec}"
  location            = var.location
  resource_group_name = var.resource_group
  sku                 = "PerGB2018"
  retention_in_days   = "30"
  tags                = var.tags
}

resource "azurerm_log_analytics_solution" "k8s" {
  count                 = var.enabled ? 1 : 0
  solution_name         = "ContainerInsights"
  location              = azurerm_log_analytics_workspace.k8s[0].location
  resource_group_name   = azurerm_log_analytics_workspace.k8s[0].resource_group_name
  workspace_resource_id = azurerm_log_analytics_workspace.k8s[0].id
  workspace_name        = azurerm_log_analytics_workspace.k8s[0].name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/ContainerInsights"
  }
}
