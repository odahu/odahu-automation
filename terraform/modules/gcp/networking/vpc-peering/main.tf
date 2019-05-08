provider "google" {
  version                   = "~> 2.2"
  region                    = "${var.region}"
  zone                      = "${var.zone}"
  project                   = "${var.project_id}"
}

# Allocate GCP Static IP
resource "google_compute_address" "vpc_gateway_ip_address" {
  name              = "${var.cluster_name}-gateway-ip"
  region            = "${var.region}"
  address_type      = "EXTERNAL"

  labels {
    "project"       = "legion"
    "cluster_name"  = "${var.cluster_name}"
  }
}
