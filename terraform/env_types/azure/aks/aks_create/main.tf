module "azure_monitoring" {
  source         = "../../../../modules/azure/monitoring"
  enabled        = var.aks_analytics_deploy
  cluster_name   = var.cluster_name
  tags           = local.common_tags
  location       = var.azure_location
  resource_group = var.azure_resource_group
}

module "aks_networking" {
  source         = "../../../../modules/azure/networking"
  cluster_name   = var.cluster_name
  tags           = local.common_tags
  location       = var.azure_location
  resource_group = var.azure_resource_group
  subnet_cidr    = var.aks_cidr
}

module "aks_bastion" {
  source          = "../../../../modules/azure/bastion"
  cluster_name    = var.cluster_name
  location        = var.azure_location
  resource_group  = var.azure_resource_group
  aks_subnet_id   = module.aks_networking.subnet_id
  allowed_ips     = var.allowed_ips
  bastion_enabled = var.bastion_enabled
  bastion_labels  = merge({ "cluster" = var.cluster_name }, var.aks_common_tags, var.bastion_labels)
}

module "aks_cluster" {
  source          = "../../../../modules/azure/aks_cluster"
  cluster_name    = var.cluster_name
  aks_tags        = local.common_tags
  location        = var.azure_location
  resource_group  = var.azure_resource_group
  aks_dns_prefix  = local.aks_dns_prefix
  aks_subnet_id   = module.aks_networking.subnet_id
  aks_subnet_cidr = var.aks_cidr
  egress_ip_name  = var.aks_egress_ip_name
  bastion_enabled = var.bastion_enabled
  bastion_ip      = module.aks_bastion.public_ip
  bastion_privkey = module.aks_bastion.privkey
  allowed_ips     = var.allowed_ips
  sp_client_id    = var.aks_sp_client_id
  sp_secret       = var.aks_sp_secret
  k8s_version     = var.k8s_version
  ssh_public_key  = var.ssh_key
  node_pools      = var.node_pools

  aks_analytics_workspace_id = var.aks_analytics_deploy ? module.azure_monitoring.workspace_id : ""
}
