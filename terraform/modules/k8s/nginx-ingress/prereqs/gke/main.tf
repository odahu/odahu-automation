resource "google_compute_address" "ingress_lb_address" {
  name         = "${var.cluster_name}-ingress-main"
  region       = var.region
  project      = var.project_id
  address_type = "EXTERNAL"
}

# Whitelist allowed_ips and cluster NAT ip on the cluster ingress
data "google_compute_address" "nat_gw_ip" {
  project = var.project_id
  region  = var.region
  name    = "${var.cluster_name}-nat-gw"
}

resource "google_compute_firewall" "ingress_access" {
  project       = var.project_id
  name          = "${var.cluster_name}-ingress-access"
  network       = var.network_name
  source_ranges = var.allowed_ips
  target_tags   = ["${var.cluster_name}-gke-node"]

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }
}

resource "google_compute_firewall" "auth_loop_access" {
  project       = var.project_id
  name          = "${var.cluster_name}-auth-access"
  network       = var.network_name
  source_ranges = ["${data.google_compute_address.nat_gw_ip.address}/32"]
  target_tags   = ["${var.cluster_name}-gke-node"]

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }
  depends_on = [google_compute_address.ingress_lb_address]
}
