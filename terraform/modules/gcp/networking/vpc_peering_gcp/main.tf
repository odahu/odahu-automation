data "google_compute_network" "gcp_network_1" {
  count   = var.infra_vpc_peering
  project = var.project_id
  name    = var.gcp_network_1_name
}

data "google_compute_network" "gcp_network_2" {
  count   = var.infra_vpc_peering
  project = var.project_id
  name    = var.gcp_network_2_name
}

resource "google_compute_network_peering" "peering1" {
  count        = var.infra_vpc_peering
  name         = "${data.google_compute_network.gcp_network_2[0].name}-${data.google_compute_network.gcp_network_1[0].name}-peering"
  network      = data.google_compute_network.gcp_network_1[0].self_link
  peer_network = data.google_compute_network.gcp_network_2[0].self_link
}

resource "google_compute_network_peering" "peering2" {
  count        = var.infra_vpc_peering
  name         = "${data.google_compute_network.gcp_network_1[0].name}-${data.google_compute_network.gcp_network_2[0].name}-peering"
  network      = data.google_compute_network.gcp_network_2[0].self_link
  peer_network = data.google_compute_network.gcp_network_1[0].self_link
  depends_on   = [google_compute_network_peering.peering1]
}

resource "google_compute_firewall" "to_network_1" {
  count         = var.infra_vpc_peering
  project       = var.project_id
  name          = substr("${data.google_compute_network.gcp_network_2[0].name}-${data.google_compute_network.gcp_network_1[0].name}", 0, 62)
  network       = data.google_compute_network.gcp_network_2[0].name
  source_ranges = var.gcp_network_1_range

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

resource "google_compute_firewall" "to_network_2" {
  count         = var.infra_vpc_peering
  project       = var.project_id
  name          = "${data.google_compute_network.gcp_network_1[0].name}-${data.google_compute_network.gcp_network_2[0].name}"
  network       = data.google_compute_network.gcp_network_1[0].name
  source_ranges = var.gcp_network_2_range

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

