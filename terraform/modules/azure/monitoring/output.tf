output "workspace_id" {
  value = var.enabled ? azurerm_log_analytics_workspace.k8s[0].id : ""
}
