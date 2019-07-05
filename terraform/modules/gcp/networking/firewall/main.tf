provider "google" {
  version                   = "~> 2.2"
  region                    = "${var.region}"
  zone                      = "${var.zone}"
  project                   = "${var.project_id}"
}

# Firewall rule that allows internal communication across all protocols
resource "google_compute_firewall" "bastion_in_fw" {
  name        = "${var.cluster_name}-bastion-in-fw"
  network     = "${var.network_name}"
  direction   = "INGRESS"

  allow {
    protocol  = "icmp"
  }

  allow {
    protocol  = "tcp"
    ports     = ["22"]
  }

  allow {
    protocol = "udp"
  }

  target_tags = ["${var.bastion_tag}"]

  source_ranges = ["${var.allowed_ips}"]
}

# Firewall rule that allows external SSH, ICMP, and HTTPS
resource "google_compute_firewall" "bastion_out_fw" {
  name        = "${var.cluster_name}-bastion-out-fw"
  network     = "${var.network_name}"
  direction   = "EGRESS"

  allow {
    protocol  = "icmp"
  }

  allow {
    protocol  = "tcp"
    ports     = ["22"]
  }

  target_tags = ["${var.bastion_tag}"]

  destination_ranges = ["0.0.0.0/0"]
}

# Firewall rule that allows kube API access to the pods
resource "google_compute_firewall" "master_to_pods_fw" {
  name        = "${var.cluster_name}-nodes-access-from-master"
  network     = "${var.network_name}"
  direction   = "INGRESS"

  allow {
    protocol  = "all"
  }

  target_tags = ["${var.gke_node_tag}"]

  source_ranges = ["${var.master_ipv4_cidr_block}"]
}