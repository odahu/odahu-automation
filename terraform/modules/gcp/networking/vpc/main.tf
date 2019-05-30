provider "google" {
  version                   = "~> 2.2"
  region                    = "${var.region}"
  zone                      = "${var.zone}"
  project                   = "${var.project_id}"
}

# Create VPC
resource "google_compute_network" "vpc" {
  name                      = "${var.cluster_name}-vpc"
  auto_create_subnetworks   = "false"
  routing_mode              = "REGIONAL"
}


resource "google_compute_subnetwork" "subnet" {
  name                      = "${var.cluster_name}-subnet"
  ip_cidr_range             = "${var.subnet_cidr}"
  network                   = "${google_compute_network.vpc.self_link}"
  region                    = "${var.region}"
  enable_flow_logs          = false
  private_ip_google_access  = true
}

resource "google_compute_router" "router" {
  name    = "${var.cluster_name}-nat-router"
  region  = "${var.region}"
  network = "${google_compute_network.vpc.self_link}"
}


resource "google_compute_address" "nat_gw_ip" {
  name              = "${var.cluster_name}-nat-gw-ip"
  region            = "${var.region}"
  address_type      = "EXTERNAL"
}

resource "google_compute_router_nat" "nat" {
  name                               = "${var.cluster_name}-nat"
  router                             = "${google_compute_router.router.name}"
  region                             = "${var.region}"
  nat_ip_allocate_option             = "MANUAL_ONLY"
  nat_ips                            = ["${google_compute_address.nat_gw_ip.self_link}"]
  # nat_ips     = "35.229.51.209"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_PRIMARY_IP_RANGES"
}