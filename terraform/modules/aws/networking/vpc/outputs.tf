# network VPC output
output "vpc_id" {
  value       = local.vpc.id
  description = "The unique name of the network"
}

output "vpc_arn" {
  value       = local.vpc.arn
  description = "The unique name of the network"
}

output "vpc_sg_id" {
  value       = local.vpc.default_security_group_id
  description = "VPC default security group ID"
}

# network subnets output

output "private_subnet_ids" {
  value       = local.private_subnet_ids
  description = "Export created CIDR range ID"
}

output "public_subnet_ids" {
  value       = local.public_subnet_ids
  description = "Export created CIDR range ID"
}

output "nat_subnet_id" {
  value       = aws_subnet.nat[0].id
  description = "Export created CIDR range ID"
}

# network route table output
output "route_table_id" {
  value = local.aws_route_table_id
}
