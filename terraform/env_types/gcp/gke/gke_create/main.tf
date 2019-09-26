########################################################
# Networking
########################################################
module "vpc" {
  source       = "../../../../modules/gcp/networking/vpc"
  project_id   = var.project_id
  region       = var.region
  cluster_name = var.cluster_name
  subnet_cidr  = var.gcp_cidr
}

module "firewall" {
  source       = "../../../../modules/gcp/networking/firewall"
  allowed_ips  = var.allowed_ips
  cluster_name = var.cluster_name
  network_name = module.vpc.network_name
  bastion_tag  = var.bastion_tag
  gke_node_tag = var.gke_node_tag
}

module "vpc_peering_gcp" {
  source              = "../../../../modules/gcp/networking/vpc_peering_gcp"
  project_id          = var.project_id
  gcp_network_1_name  = module.vpc.network_name
  gcp_network_1_range = [var.gcp_cidr, module.gke_cluster.k8s_pods_cidr]
  gcp_network_2_name  = var.infra_vpc_name
  gcp_network_2_range = [var.infra_cidr]
}

########################################################
# IAM
########################################################
module "iam" {
  source       = "../../../../modules/gcp/iam"
  project_id   = var.project_id
  cluster_name = var.cluster_name
}

########################################################
# GKE Cluster
########################################################
module "gke_cluster" {
  source               = "../../../../modules/gcp/gke_cluster"
  project_id           = var.project_id
  cluster_name         = var.cluster_name
  region               = var.region
  zone                 = var.zone
  allowed_ips          = var.allowed_ips
  agent_cidr           = var.agent_cidr
  nodes_sa             = module.iam.service_account
  pods_cidr            = var.pods_cidr
  service_cidr         = var.service_cidr
  location             = var.location
  node_locations       = var.node_locations
  initial_node_count   = var.initial_node_count
  network              = module.vpc.network_name
  subnetwork           = module.vpc.subnet_name
  dns_zone_name        = var.dns_zone_name
  root_domain          = var.root_domain
  k8s_version          = var.k8s_version
  node_version         = var.node_version
  bastion_tag          = var.bastion_tag
  gke_node_tag         = var.gke_node_tag
  ssh_public_key       = var.ssh_key
}