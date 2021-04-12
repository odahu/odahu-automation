########################################################
# Networking
########################################################
module "vpc" {
  source               = "../../../../modules/aws/networking/vpc"
  cluster_name         = var.cluster_name
  cidr                 = var.cidr
  az_list              = var.az_list
  aws_region           = var.aws_region
  nat_subnet_cidr      = var.nat_subnet_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
}

module "firewall" {
  source          = "../../../../modules/aws/networking/firewall"
  allowed_ips     = var.allowed_ips
  cluster_name    = var.cluster_name
  vpc_id          = module.vpc.vpc_id
  vpc_sg_id       = module.vpc.vpc_sg_id
  bastion_enabled = var.bastion_enabled
  depends_on      = [module.vpc]
}

module "iam" {
  source       = "../../../../modules/aws/iam"
  cluster_name = var.cluster_name
  kms_key_arn  = var.kms_key_arn
}

module "eks" {
  source                     = "../../../../modules/aws/eks_cluster"
  allowed_ips                = var.allowed_ips
  k8s_version                = var.k8s_version
  cluster_name               = var.cluster_name
  vpc_id                     = module.vpc.vpc_id
  node_pools                 = try(merge(var.node_pools, var.argo.node_pool), var.node_pools)
  master_role_arn            = module.iam.master_role_arn
  master_sg_id               = module.firewall.master_sg_id
  node_role_arn              = module.iam.node_role_arn
  node_sg_id                 = module.firewall.node_sg_id
  node_instance_profile_name = module.iam.node_instance_profile_name
  bastion_enabled            = var.bastion_enabled
  bastion_sg_id              = module.firewall.bastion_sg_id
  subnet_ids                 = module.vpc.private_subnet_ids
  nat_subnet_id              = module.vpc.nat_subnet_id
  aws_region                 = var.aws_region
  kms_key_arn                = var.kms_key_arn
  service_linked_role_arn    = module.iam.service_role_arn

  depends_on = [
    module.vpc,
    module.iam,
    module.firewall
  ]
}

module "kms_storage_class" {
  count = var.kms_key_arn == "" ? 0 : 1

  source       = "../../../../modules/aws/storage"
  kms_key_arn  = var.kms_key_arn
  cluster_name = var.cluster_name

  depends_on = [module.eks]
}

