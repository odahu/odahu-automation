########################################################
# Networking
########################################################
module "vpc" {
  source                      = "../../../modules/gcp/networking/vpc"
  project_id                  = "${var.project_id}"
  region                      = "${var.region}"
  zone                        = "${var.zone}"
  cluster_name                = "${var.cluster_name}"
  subnet_cidr                 = "${var.gcp_cidr}"
}

module "firewall" {
  source                      = "../../../modules/gcp/networking/firewall"
  project_id                  = "${var.project_id}"
  region                      = "${var.region}"
  zone                        = "${var.zone}"
  allowed_ips                 = "${var.allowed_ips}"
  cluster_name                = "${var.cluster_name}"
  network_name                = "${module.vpc.network_name}"
  bastion_tag                 = "${var.cluster_name}-bastion"
}

module "vpc_peering" {
  source                      = "../../../modules/gcp/networking/vpc_peering"
  project_id                  = "${var.project_id}"
  region                      = "${var.region}"
  zone                        = "${var.zone}"
  cluster_name                = "${var.cluster_name}"
  region_aws                  = "${var.region_aws}"
  aws_profile                 = "${var.aws_profile}"
  aws_credentials_file        = "${var.aws_credentials_file}"
  aws_vpc_id                  = "${var.aws_vpc_id}"
  gcp_cidr                    = "${var.gcp_cidr}"
  aws_sg                      = "${var.aws_sg}"
  aws_cidr                    = "${var.aws_cidr}"
  gcp_network                 = "${module.vpc.network_name}"
  aws_route_table_id          = "${var.aws_route_table_id}"
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
  source                      = "../../../modules/gcp/gke_cluster"
  project_id                  = "${var.project_id}"
  cluster_name                = "${var.cluster_name}"
  region                      = "${var.region}"
  zone                        = "${var.zone}"
  region_aws                  = "${var.region_aws}"
  aws_profile                 = "${var.aws_profile}"
  aws_credentials_file        = "${var.aws_credentials_file}"
  location                    = "${var.location}"
  allowed_ips                 = "${var.allowed_ips}"
  agent_cidr                  = "${var.agent_cidr}"
  nodes_sa                    = "${module.iam.service_account}"
  gke_node_machine_type       = "${var.gke_node_machine_type}"
  location                    = "${var.location}"
  network                     = "${module.vpc.network_name}"
  subnetwork                  = "${module.vpc.subnet_name}"
  dns_zone_name               = "${var.dns_zone_name}"
  root_domain                 = "${var.root_domain}"
  secrets_storage             = "${var.secrets_storage}"
  bastion_tags                = ["${var.cluster_name}-bastion"]
  config_context_auth_info    = "${var.config_context_auth_info}"
  config_context_cluster      = "${var.config_context_cluster}"
}