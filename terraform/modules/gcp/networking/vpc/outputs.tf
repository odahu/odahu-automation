# network VPC output
output "network_name" {
  value       = length(var.vpc_name) == 0 ? google_compute_network.vpc[0].name : data.google_compute_network.vpc[0].name
  description = "The unique name of the network"
}

output "self_link" {
  value       = length(var.vpc_name) == 0 ? google_compute_network.vpc[0].self_link : data.google_compute_network.vpc[0].self_link
  description = "The URL of the created resource"
}

# network subnet output
output "ip_cidr_range" {
  value       = length(var.subnet_name) == 0 ? google_compute_subnetwork.subnet[0].ip_cidr_range : data.google_compute_subnetwork.subnet[0].ip_cidr_range
  description = "Export created CICDR range"
}

output "subnet_name" {
  value       = length(var.subnet_name) == 0 ? google_compute_subnetwork.subnet[0].name : data.google_compute_subnetwork.subnet[0].name
  description = "Export created CICDR range"
}

