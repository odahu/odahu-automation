output "k8s_api_address" {
  value = local.aks_cluser_resource.kube_config.0.host
}
