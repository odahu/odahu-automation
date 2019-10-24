# network VPC output
output "vpc_id" {
  value       = aws_vpc.default.id
  description = "The unique name of the network"
}

output "vpc_arn" {
  value       = aws_vpc.default.arn
  description = "The unique name of the network"
}

output "vpc_sg_id" {
  value       = aws_vpc.default.default_security_group_id
  description = "VPC default security group ID"
}

# network subnets output

output "private_subnet_ids" {
  value       = aws_subnet.private.*.id
  description = "Export created CIDR range ID"
}

output "public_subnet_ids" {
  value       = aws_subnet.public.*.id
  description = "Export created CIDR range ID"
}

output "nat_subnet_id" {
  value       = aws_subnet.nat.id
  description = "Export created CIDR range ID"
}

# network route table output
output "route_table_id" {
  value = aws_route_table.default.id
}
