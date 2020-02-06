output "bastion_address" {
  value = var.bastion_enabled ? aws_instance.bastion[0].public_ip : null
}

output "k8s_api_address" {
  value = aws_eks_cluster.default.endpoint
}
