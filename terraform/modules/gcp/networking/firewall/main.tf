# VPC firewall configuration
# Create a firewall rule that allows internal communication across all protocols:
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

# Create a firewall rule that allows external SSH, ICMP, and HTTPS:
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
