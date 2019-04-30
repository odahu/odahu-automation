provider "google" {
  version     = "~> 2.2"
  region      = "${var.region}"
  zone        = "${var.zone}"
  project     = "${var.project_id}"
}


########################################################
# Networking
########################################################
module "networking" {
  source                      = "../../../modules/gcp/networking/network"
  region                      = "${var.region}"
  cluster_name                = "${var.cluster_name}"
}

module "firewall" {
  source                      = "../../../modules/gcp/networking/firewall"
  allowed_ips                 = "${var.allowed_ips}"
  cluster_name                = "${var.cluster_name}"
  network_name                = "${module.networking.network_name}"
  bastion_tag                 = "${var.cluster_name}-bastion"
}

########################################################
# IAM
########################################################
module "iam" {
  source                      = "../../../modules/gcp/iam"
  project_id                  = "${var.project_id}"
  cluster_name                = "${var.cluster_name}"
  region                      = "${var.region}"
  zone                        = "${var.zone}"
}

########################################################
# GKE Cluster
########################################################
module "gke_cluster" {
  source                      = "../../modules/gcp/gke_cluster"
  project_id                  = "${var.project_id}"
  cluster_name                = "${var.cluster_name}"
  zone                        = "${var.zone}"
  location                    = "${var.location}"
  allowed_ips                 = "${var.allowed_ips}"
  nodes_sa                    = "${module.iam.service_account}"
  gke_node_machine_type       = "${var.gke_node_machine_type}"
  location                    = "${var.location}"
  network                     = "${module.networking.network_name}"
  subnetwork                  = "${module.networking.subnet_name}"
  dns_zone_name               = "${var.dns_zone_name}"
  root_domain                 = "${var.root_domain}"
  secrets_storage             = "${var.secrets_storage}"
  bastion_tags                = ["${var.cluster_name}-bastion"]
}
