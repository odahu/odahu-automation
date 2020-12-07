output "service_role_arn" {
  value = aws_iam_service_linked_role.autoscaling.arn
}

output "service_role_id" {
  value = aws_iam_service_linked_role.autoscaling.id
}

output "master_role_arn" {
  value = aws_iam_role.master.arn
}

output "master_role_id" {
  value = aws_iam_role.master.id
}

output "node_role_arn" {
  value = aws_iam_role.node.arn
}

output "node_role_id" {
  value = aws_iam_role.node.id
}

output "node_instance_profile_name" {
  value = aws_iam_instance_profile.node.name
}
