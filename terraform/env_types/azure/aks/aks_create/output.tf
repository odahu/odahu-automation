output "k8s_api_address" {
  value = module.aks_cluster.k8s_api_address
}

output "bastion_address" {
  value = module.aks_bastion.public_ip == "" ? null : module.aks_bastion.public_ip
}
