output "k8s_api_address" {
  value = azurerm_kubernetes_cluster.aks[0].kube_config.0.host
}

output "kube_config" {
  value = azurerm_kubernetes_cluster.aks[0].kube_config_raw
}