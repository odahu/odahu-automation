# TODO: handle issue with output errors after failed destroy run
output "cluster_endpoint" {
  value = module.eks.k8s_api_address
}

output subnet_ids {
  value = module.vpc.private_subnet_ids
}

output "bastion_address" {
  value = module.eks.bastion_address
}

output "k8s_api_address" {
  value = module.eks.k8s_api_address
}
