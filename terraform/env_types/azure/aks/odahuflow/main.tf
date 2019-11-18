data "azurerm_kubernetes_cluster" "aks" {
  name                = var.cluster_name
  resource_group_name = var.azure_resource_group
}

locals {
  config_context_auth_info = data.azurerm_kubernetes_cluster.aks.kube_config.0.username
  config_context_cluster   = var.cluster_name
  common_tags = merge(
    { "cluster" = var.cluster_name },
    var.aks_common_tags
  )
}

########################################################
# Odahuflow setup
########################################################
module "odahuflow_prereqs" {
  source         = "../../../../modules/odahuflow_aks"
  tags           = local.common_tags
  location       = var.azure_location
  resource_group = var.azure_resource_group
  cluster_name   = var.cluster_name
  data_bucket    = var.data_bucket
  ip_egress_name = var.aks_egress_ip_name
  allowed_ips    = var.allowed_ips
}

module "odahuflow" {
  source         = "../../../../modules/odahuflow"
  tls_secret_crt = var.tls_crt
  tls_secret_key = var.tls_key
  root_domain    = var.root_domain
  cluster_name   = var.cluster_name
  cluster_type   = var.cluster_type
  cloud_type     = var.cloud_type

  odahuflow_version = var.odahuflow_version
  helm_repo         = var.helm_repo
  data_bucket       = var.data_bucket

  azure_storage_account = module.odahuflow_prereqs.storage_account

  model_docker_user        = module.odahuflow_prereqs.model_docker_user
  model_docker_repo        = module.odahuflow_prereqs.model_docker_repo
  model_docker_password    = module.odahuflow_prereqs.model_docker_password
  model_docker_url         = var.model_docker_url
  model_docker_web_ui_link = module.odahuflow_prereqs.model_docker_web_ui_link

  model_output_bucket      = module.odahuflow_prereqs.model_output_bucket
  model_output_secret      = module.odahuflow_prereqs.model_output_secret
  model_output_web_ui_link = module.odahuflow_prereqs.model_output_web_ui_link

  dockercfg       = module.odahuflow_prereqs.dockercfg
  docker_repo     = var.docker_repo
  docker_user     = var.docker_user
  docker_password = var.docker_password

  feedback_storage_link = module.odahuflow_prereqs.feedback_storage_link

  git_examples_key       = var.git_examples_key
  git_examples_uri       = var.git_examples_uri
  git_examples_reference = var.git_examples_reference

  model_resources_cpu      = var.model_resources_cpu
  model_resources_mem      = var.model_resources_mem
  mlflow_toolchain_version = var.mlflow_toolchain_version

  odahuflow_connection_decrypt_token = var.odahuflow_connection_decrypt_token

  jupyterlab_version = var.jupyterlab_version
  packager_version   = var.packager_version
}
