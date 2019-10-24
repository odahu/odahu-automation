# TODO: handle issue with output errors after failed destroy run
output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output subnet_ids {
  value = module.vpc.private_subnet_ids
}
