# network VPC output
# output "vpc_name" {
#   value       = "${module.vpc.vpc_name}"
#   description = "The unique name of the network"
# }

# # subnet cidr ip range
# output "ip_cidr_range" {
#   value       = "${module.subnet.ip_cidr_range}"
#   description = "Export created CICDR range"
# }

# GKE outputs
output "kubernetes_endpoint" {
  sensitive = true
  value     = "${module.gcp.endpoint}"
}

output "client_token" {
  sensitive = true
  value     = "${base64encode(data.google_client_config.default.access_token)}"
}

output "ca_certificate" {
  value = "${module.gcp.ca_certificate}"
}

output "service_account" {
  description = "The service account to default running nodes as if not overridden in `node_pools`."
  value       = "${module.gcp.service_account}"
}