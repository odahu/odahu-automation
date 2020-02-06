########################################################
# Networking
########################################################
module "vpc" {
  source       = "../../../../modules/gcp/networking/vpc"
  project_id   = local.gcp_project_id
  region       = var.gcp_region
  cluster_name = var.cluster_name
  subnet_cidr  = var.gcp_cidr
  subnet_name  = var.subnet_name
  vpc_name     = var.vpc_name
}

module "firewall" {
  source        = "../../../../modules/gcp/networking/firewall"
  allowed_ips   = var.allowed_ips
  cluster_name  = var.cluster_name
  network_name  = module.vpc.network_name
  gke_node_tags = local.gke_node_tags

  bastion_enabled = var.bastion_enabled
  bastion_tags    = local.bastion_tags
}

module "vpc_peering_gcp" {
  source              = "../../../../modules/gcp/networking/vpc_peering_gcp"
  project_id          = local.gcp_project_id
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
  project_id   = local.gcp_project_id
  cluster_name = var.cluster_name
}

########################################################
# GKE Cluster
########################################################
module "gke_cluster" {
  source             = "../../../../modules/gcp/gke_cluster"
  cluster_name       = var.cluster_name
  gcp_project_id     = local.gcp_project_id
  gcp_zone           = var.gcp_zone
  gcp_region         = var.gcp_region
  allowed_ips        = var.allowed_ips
  nodes_sa           = module.iam.service_account
  node_pools         = var.node_pools
  pods_cidr          = var.pods_cidr
  service_cidr       = var.service_cidr
  node_locations     = var.node_locations
  network            = module.vpc.network_name
  subnetwork         = module.vpc.subnet_name
  k8s_version        = var.k8s_version
  node_version       = local.node_version
  gke_node_tags      = local.gke_node_tags
  gke_node_labels    = var.gke_node_labels
  ssh_public_key     = var.ssh_key

  bastion_enabled      = var.bastion_enabled
  bastion_hostname     = var.bastion_hostname
  bastion_machine_type = var.bastion_machine_type
  bastion_tags         = local.bastion_tags
  bastion_labels       = var.bastion_labels
}
