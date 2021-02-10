########################################################
# Networking
########################################################
module "vpc" {
  source       = "../../../../modules/gcp/networking/vpc"
  project_id   = var.project_id
  region       = var.region
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
  node_gcp_tags = local.node_gcp_tags

  bastion_enabled  = var.bastion_enabled
  bastion_gcp_tags = local.bastion_gcp_tags

  depends_on = [module.vpc]
}

module "vpc_peering_gcp" {
  source              = "../../../../modules/gcp/networking/vpc_peering_gcp"
  project_id          = var.project_id
  gcp_network_1_name  = module.vpc.network_name
  gcp_network_1_range = [var.gcp_cidr, module.gke_cluster.k8s_pods_cidr]
  gcp_network_2_name  = var.infra_vpc_name
  gcp_network_2_range = var.infra_cidr == "" ? [] : [var.infra_cidr]

  depends_on = [
    module.vpc,
    module.gke_cluster
  ]
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
  source         = "../../../../modules/gcp/gke_cluster"
  project_id     = var.project_id
  cluster_name   = var.cluster_name
  zone           = var.zone
  allowed_ips    = var.allowed_ips
  nodes_sa       = module.iam.service_account
  node_pools     = var.node_pools
  pods_cidr      = var.pods_cidr
  service_cidr   = var.service_cidr
  location       = var.region
  node_locations = var.node_locations
  network        = module.vpc.network_name
  subnetwork     = module.vpc.subnet_name
  k8s_version    = var.k8s_version
  node_version   = var.node_version
  node_gcp_tags  = local.node_gcp_tags
  node_labels    = var.node_labels
  ssh_public_key = var.ssh_key
  kms_key_id     = var.kms_key_id

  bastion_enabled      = var.bastion_enabled
  bastion_hostname     = var.bastion_hostname
  bastion_machine_type = var.bastion_machine_type
  bastion_gcp_tags     = local.bastion_gcp_tags
  bastion_labels       = var.bastion_labels

  block_project_ssh_key = var.block_project_ssh_key

  depends_on = [
    module.iam,
    module.vpc
  ]
}
