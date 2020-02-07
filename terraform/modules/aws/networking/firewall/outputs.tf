output "master_sg_arn" {
  value = aws_security_group.master.arn
}

output "master_sg_id" {
  value = aws_security_group.master.id
}

output "node_sg_arn" {
  value = aws_security_group.node.arn
}

output "node_sg_id" {
  value = aws_security_group.node.id
}

output "bastion_sg_arn" {
  value = var.bastion_enabled ? aws_security_group.bastion[0].arn : ""
}

output "bastion_sg_id" {
  value = var.bastion_enabled ? aws_security_group.bastion[0].id : ""
}
