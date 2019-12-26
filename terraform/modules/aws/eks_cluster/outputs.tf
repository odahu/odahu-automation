output "bastion_address" {
  value = aws_instance.bastion.public_ip
}

output "k8s_api_address" {
  value = aws_eks_cluster.default.endpoint
}


