output "bastion_address" {
  value = module.gke_cluster.bastion_address
}

output "k8s_api_address" {
  value = module.gke_cluster.k8s_api_address
}

