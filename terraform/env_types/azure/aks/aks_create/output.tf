output "k8s_api_address" {
  value = module.aks_cluster.k8s_api_address
}

output "kube_config" {
  value = module.aks_cluster.kube_config
}

output "bastion_address" {
  value = module.aks_networking.bastion_ip == "" ? null : module.aks_networking.bastion_ip
}
