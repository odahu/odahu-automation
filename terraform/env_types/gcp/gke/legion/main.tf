########################################################
# Legion setup
########################################################
module "legion" {
  source                   = "../../../../modules/legion"
  config_context_auth_info = var.config_context_auth_info
  config_context_cluster   = var.config_context_cluster
  aws_profile              = var.aws_profile
  aws_credentials_file     = var.aws_credentials_file
  zone                     = var.zone
  region                   = var.region
  region_aws               = var.region_aws
  project_id               = var.project_id
  secrets_storage          = var.secrets_storage
  legion_helm_repo         = var.legion_helm_repo
  root_domain              = var.root_domain
  cluster_name             = var.cluster_name
  docker_repo              = var.docker_repo
  docker_user              = var.docker_user
  docker_password          = var.docker_password
  legion_version           = var.legion_version
  collector_region         = var.collector_region
  legion_data_bucket       = var.legion_data_bucket
  git_examples_key         = var.git_examples_key
  model_docker_url         = var.model_docker_url
  git_examples_uri         = var.git_examples_uri
  git_examples_reference   = var.git_examples_reference
  model_resources_cpu      = var.model_resources_cpu
  model_resources_mem      = var.model_resources_mem
  api_private_key          = var.api_private_key
  api_public_key           = var.api_public_key
  mlflow_toolchain_version = var.mlflow_toolchain_version
}

