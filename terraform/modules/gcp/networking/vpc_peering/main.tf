provider "google" {
  version                   = "~> 2.2"
  region                    = "${var.region}"
  zone                      = "${var.zone}"
  project                   = "${var.project_id}"
}

provider "aws" {
  region                    = "${var.region_aws}"
  shared_credentials_file   = "${var.aws_credentials_file}"
  profile                   = "${var.aws_profile}"
}

# Allocate GCP Static IP for VPN
resource "google_compute_address" "vpn_gateway_ip_address" {
  name              = "${var.cluster_name}-gateway-ip"
  region            = "${var.region}"
  address_type      = "EXTERNAL"
}

#############################
# AWS Side
#############################

# Customer Gateway at AWS
resource "aws_customer_gateway" "to_gcp" {
  bgp_asn    = 65000
  ip_address = "${google_compute_address.vpn_gateway_ip_address.address}"
  type       = "ipsec.1"
  tags = {
    Name    = "${var.cluster_name}-gcp"
    Project = "legion"
  }
}

# Virtual Private gateway at AWS
resource "aws_vpn_gateway" "vpn_gateway" {
  vpc_id    = "${var.aws_vpc_id}"
  tags = {
    Name    = "${var.cluster_name}-gcp"
    Project = "legion"
  }
}

# VPN Connection at AWS
resource "aws_vpn_connection" "to_gcp" {
  vpn_gateway_id      = "${aws_vpn_gateway.vpn_gateway.id}"
  customer_gateway_id = "${aws_customer_gateway.to_gcp.id}"
  type                = "ipsec.1"
  static_routes_only  = true
  tags = {
    Name    = "${var.cluster_name}-gcp"
    Project = "legion"
  }
}

# VPN Connection route to GCP
resource "aws_vpn_connection_route" "gcp" {
  destination_cidr_block = "${var.gcp_cidr}"
  vpn_connection_id      = "${aws_vpn_connection.to_gcp.id}"
}

resource "aws_route" "gcp" {
  route_table_id         = "${var.aws_route_table_id}"
  gateway_id             = "${aws_vpn_gateway.vpn_gateway.id}"
  destination_cidr_block = "${var.gcp_cidr}"
}

# Allow inbound access to VPC resources from GCP CIDR
resource "aws_security_group_rule" "google_ingress_vpn" {
  type        = "ingress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["${var.gcp_cidr}"]
  security_group_id = "${var.aws_sg}"
}

# Allow outbound access from VPC resources to GCP CIDR
resource "aws_security_group_rule" "google_egress_vpn" {
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["${var.gcp_cidr}"]
  security_group_id = "${var.aws_sg}"
}

#############################
# GCP Side
#############################

resource "google_compute_vpn_gateway" "gcp" {
  name    = "gcp-vpn"
  network = "${var.gcp_network}"
  region  = "${var.region}"
}

resource "google_compute_forwarding_rule" "fr_esp" {
  name        = "fr-esp"
  region      = "${var.region}"
  ip_protocol = "ESP"
  ip_address  = "${google_compute_address.vpn_gateway_ip_address.address}"
  target      = "${google_compute_vpn_gateway.gcp.self_link}"
}

resource "google_compute_forwarding_rule" "fr_udp500" {
  name        = "fr-udp500"
  region      = "${var.region}"
  ip_protocol = "UDP"
  port_range  = "500-500"
  ip_address  = "${google_compute_address.vpn_gateway_ip_address.address}"
  target      = "${google_compute_vpn_gateway.gcp.self_link}"
}

resource "google_compute_forwarding_rule" "fr_udp4500" {
  name        = "fr-udp4500"
  region      = "${var.region}"
  ip_protocol = "UDP"
  port_range  = "4500-4500"
  ip_address  = "${google_compute_address.vpn_gateway_ip_address.address}"
  target      = "${google_compute_vpn_gateway.gcp.self_link}"
}

resource "google_compute_vpn_tunnel" "tunnel1" {
  name          = "gcp-tunnel-1"
  ike_version   = "1"
  region        = "${var.region}"
  peer_ip       = "${aws_vpn_connection.to_gcp.tunnel1_address}"
  shared_secret = "${aws_vpn_connection.to_gcp.tunnel1_preshared_key}"
  local_traffic_selector  = ["${var.gcp_cidr}"]
  target_vpn_gateway = "${google_compute_vpn_gateway.gcp.self_link}"

  depends_on = [
    "google_compute_forwarding_rule.fr_esp",
    "google_compute_forwarding_rule.fr_udp500",
    "google_compute_forwarding_rule.fr_udp4500",
  ]
}

resource "google_compute_route" "gcp_route1" {
  name       = "gcp-route1"
  network    = "${var.gcp_network}"
  dest_range = "${var.aws_cidr}"
  priority   = 1000

  next_hop_vpn_tunnel = "${google_compute_vpn_tunnel.tunnel1.self_link}"
}

resource "google_compute_vpn_tunnel" "tunnel2" {
  name                    = "gcp-tunnel-2"
  ike_version             = "1"
  region                  = "${var.region}"
  peer_ip                 = "${aws_vpn_connection.to_gcp.tunnel2_address}"
  shared_secret           = "${aws_vpn_connection.to_gcp.tunnel2_preshared_key}"
  local_traffic_selector  = ["${var.gcp_cidr}"]
  target_vpn_gateway      = "${google_compute_vpn_gateway.gcp.self_link}"

  depends_on = [
    "google_compute_forwarding_rule.fr_esp",
    "google_compute_forwarding_rule.fr_udp500",
    "google_compute_forwarding_rule.fr_udp4500",
  ]
}

resource "google_compute_route" "gcp_route2" {
  name       = "gcp-route2"
  network    = "${var.gcp_network}"
  dest_range = "${var.aws_cidr}"
  priority   = 1000

  next_hop_vpn_tunnel = "${google_compute_vpn_tunnel.tunnel2.self_link}"
}

resource "google_compute_firewall" "aws_vpn" {
  name          = "aws"
  network       = "${var.gcp_network}"
  source_ranges = ["${var.aws_cidr}"]

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
  }

  allow {
    protocol = "udp"
  }
}