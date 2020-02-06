locals {
  network_name = var.network_name == "" ? "${var.cluster_name}-vpc" : var.network_name
}

# Firewall rule that allows internal communication across all protocols
resource "google_compute_firewall" "bastion_in_fw" {
  count     = var.bastion_enabled ? 1 : 0
  name      = "${var.cluster_name}-bastion-in-fw"
  network   = local.network_name
  direction = "INGRESS"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  allow {
    protocol = "udp"
  }

  target_tags = var.bastion_tags

  source_ranges = var.allowed_ips
}

# Firewall rule that allows external SSH, ICMP, and HTTPS
resource "google_compute_firewall" "bastion_out_fw" {
  count     = var.bastion_enabled ? 1 : 0
  name      = "${var.cluster_name}-bastion-out-fw"
  network   = local.network_name
  direction = "EGRESS"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  target_tags = var.bastion_tags

  destination_ranges = ["0.0.0.0/0"]
}

# Firewall rule that allows kube API access to the pods
resource "google_compute_firewall" "master_to_pods_fw" {
  name      = "${var.cluster_name}-nodes-access-from-master"
  network   = local.network_name
  direction = "INGRESS"

  allow {
    protocol = "all"
  }

  target_tags = var.gke_node_tags

  source_ranges = [var.master_ipv4_cidr_block]
}
