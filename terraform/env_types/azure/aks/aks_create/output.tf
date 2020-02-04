output "k8s_api_address" {
  value = module.aks_cluster.k8s_api_address
}

output "kube_config" {
  value     = module.aks_cluster.kube_config
  sensitive = true
}

output "bastion_address" {
  value = module.aks_networking.bastion_ip
}
