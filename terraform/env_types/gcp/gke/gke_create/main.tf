########################################################
# Networking
########################################################
module "vpc" {
  source       = "../../../../modules/gcp/networking/vpc"
  project_id   = var.project_id
  region       = var.region
  zone         = var.zone
  cluster_name = var.cluster_name
  subnet_cidr  = var.gcp_cidr
}

module "firewall" {
  source       = "../../../../modules/gcp/networking/firewall"
  project_id   = var.project_id
  region       = var.region
  zone         = var.zone
  allowed_ips  = var.allowed_ips
  cluster_name = var.cluster_name
  network_name = module.vpc.network_name
  bastion_tag  = var.bastion_tag
  gke_node_tag = var.gke_node_tag
}

module "vpc_peering" {
  source               = "../../../../modules/gcp/networking/vpc_peering"
  project_id           = var.project_id
  region               = var.region
  zone                 = var.zone
  cluster_name         = var.cluster_name
  region_aws           = var.region_aws
  aws_profile          = var.aws_profile
  aws_credentials_file = var.aws_credentials_file
  aws_vpc_id           = var.aws_vpc_id
  gcp_cidr             = var.gcp_cidr
  aws_sg               = var.aws_sg
  aws_cidr             = var.aws_cidr
  gcp_network          = module.vpc.network_name
  aws_route_table_id   = var.aws_route_table_id
}

module "vpc_peering_gce" {
  source                      = "../../../../modules/gcp/networking/vpc_peering_gce"
  project_id                  = var.project_id
  region                      = var.region
  zone                        = var.zone
  gcp_network_1_name          = module.vpc.network_name
  gcp_network_1_range         = [var.gcp_cidr, var.pods_cidr]
  gcp_network_2_name          = var.infra_vpc_name
  gcp_network_2_range         = [var.infra_cidr]
}
########################################################
# IAM
########################################################
module "iam" {
  source       = "../../../../modules/gcp/iam"
  project_id   = var.project_id
  cluster_name = var.cluster_name
  region       = var.region
  zone         = var.zone
}

########################################################
# GKE Cluster
########################################################
module "gke_cluster" {
  source                = "../../../../modules/gcp/gke_cluster"
  project_id            = var.project_id
  cluster_name          = var.cluster_name
  region                = var.region
  zone                  = var.zone
  region_aws            = var.region_aws
  aws_profile           = var.aws_profile
  aws_credentials_file  = var.aws_credentials_file
  allowed_ips           = var.allowed_ips
  agent_cidr            = var.agent_cidr
  nodes_sa              = module.iam.service_account
  gke_node_machine_type = var.gke_node_machine_type
  location              = var.location
  network               = module.vpc.network_name
  subnetwork            = module.vpc.subnet_name
  dns_zone_name         = var.dns_zone_name
  root_domain           = var.root_domain
  secrets_storage       = var.secrets_storage
  k8s_version           = var.k8s_version
  node_version          = var.node_version
  bastion_tag           = var.bastion_tag
  gke_node_tag          = var.gke_node_tag
}
