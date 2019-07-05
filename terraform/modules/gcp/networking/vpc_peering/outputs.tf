# network VPC output
output "gcp_ip_address"  {
  value       = "${google_compute_address.vpn_gateway_ip_address.address}"
  description = "Static IP address"
}
output "aws_customer_gw_id" {
  value       = "${aws_customer_gateway.to_gcp.id}"
  description = "AWS Customer gateway id"
}
output "aws_connection_config" {
  value       = "${aws_vpn_connection.to_gcp.customer_gateway_configuration}"
  description = "AWS Connection config"
}