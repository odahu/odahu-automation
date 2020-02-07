# network VPC output
output "network_name" {
  value       = local.vpc.name
  description = "The unique name of the network"
}

output "self_link" {
  value       = local.vpc.self_link
  description = "The URL of the created resource"
}

# network subnet output
output "ip_cidr_range" {
  value       = local.subnet.ip_cidr_range
  description = "Export created CIDR range"
}

output "subnet_name" {
  value       = local.subnet.name
  description = "Export created CICDR range"
}
