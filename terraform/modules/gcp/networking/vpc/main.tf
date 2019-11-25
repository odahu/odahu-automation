# Create VPC
resource "google_compute_network" "vpc" {
  project                 = var.project_id
  name                    = "${var.cluster_name}-vpc"
  auto_create_subnetworks = "false"
  routing_mode            = "REGIONAL"
}

resource "google_compute_subnetwork" "subnet" {
  project                  = var.project_id
  name                     = "${var.cluster_name}-subnet"
  ip_cidr_range            = var.subnet_cidr
  network                  = google_compute_network.vpc.self_link
  region                   = var.region
  private_ip_google_access = true
}

resource "google_compute_router" "router" {
  name    = "${var.cluster_name}-nat-router"
  region  = var.region
  network = google_compute_network.vpc.self_link
}

data "google_compute_address" "nat_gw_ip" {
  name = "${var.cluster_name}-nat-gw"
}

resource "google_compute_router_nat" "nat" {
  name                               = "${var.cluster_name}-nat"
  router                             = google_compute_router.router.name
  region                             = var.region
  nat_ip_allocate_option             = "MANUAL_ONLY"
  nat_ips                            = [data.google_compute_address.nat_gw_ip.self_link]
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_PRIMARY_IP_RANGES"
}

