########################################################
# Legion setup
########################################################
module "legion_prereqs" {
  source             = "../../../../modules/legion_eks"
  region             = var.aws_region
  cluster_name       = var.cluster_name
  legion_data_bucket = var.legion_data_bucket
}

module "legion" {
  source           = "../../../../modules/legion"
  aws_region       = var.aws_region
  tls_secret_crt   = var.tls_crt
  tls_secret_key   = var.tls_key
  legion_helm_repo = var.legion_helm_repo
  root_domain      = var.root_domain
  cluster_name     = var.cluster_name
  cluster_type     = "aws/eks"
  cloud_type       = "aws"

  model_docker_user     = module.legion_prereqs.model_docker_user
  model_docker_repo     = module.legion_prereqs.model_docker_repo
  model_docker_password = module.legion_prereqs.model_docker_password
  model_output_bucket   = module.legion_prereqs.model_output_bucket
  bucket_registry_name  = module.legion_prereqs.bucket_registry_name
  dockercfg             = module.legion_prereqs.dockercfg

  model_output_web_ui_link  = module.legion_prereqs.model_output_web_ui_link
  feedback_storage_link     = module.legion_prereqs.feedback_storage_link
  model_output_region       = module.legion_prereqs.model_output_region
  model_docker_web_ui_link  = module.legion_prereqs.model_docker_web_ui_link
  model_output_secret       = module.legion_prereqs.model_output_secret
  model_output_secret_key   = module.legion_prereqs.model_output_secret_key
  legion_data_bucket_region = module.legion_prereqs.legion_data_bucket_region

  docker_repo     = var.docker_repo
  docker_user     = var.docker_user
  docker_password = var.docker_password

  legion_version            = var.legion_version
  collector_region          = var.collector_region
  legion_collector_iam_role = module.legion_prereqs.legion_collector_iam_role
  legion_data_bucket        = var.legion_data_bucket
  git_examples_key          = var.git_examples_key
  model_docker_url          = var.model_docker_url
  git_examples_uri          = var.git_examples_uri
  git_examples_reference    = var.git_examples_reference
  model_resources_cpu       = var.model_resources_cpu
  model_resources_mem       = var.model_resources_mem
  mlflow_toolchain_version  = var.mlflow_toolchain_version
}

