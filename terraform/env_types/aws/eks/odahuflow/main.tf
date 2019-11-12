########################################################
# Odahuflow setup
########################################################
module "odahuflow_prereqs" {
  source             = "../../../../modules/odahuflow_eks"
  region             = var.aws_region
  cluster_name       = var.cluster_name
  data_bucket = var.data_bucket
}

module "odahuflow" {
  source           = "../../../../modules/odahuflow"
  aws_region       = var.aws_region
  tls_secret_crt   = var.tls_crt
  tls_secret_key   = var.tls_key
  helm_repo = var.helm_repo
  root_domain      = var.root_domain
  cluster_name     = var.cluster_name
  cluster_type     = "aws/eks"
  cloud_type       = "aws"

  model_docker_user     = module.odahuflow_prereqs.model_docker_user
  model_docker_repo     = module.odahuflow_prereqs.model_docker_repo
  model_docker_password = module.odahuflow_prereqs.model_docker_password
  model_output_bucket   = module.odahuflow_prereqs.model_output_bucket
  bucket_registry_name  = module.odahuflow_prereqs.bucket_registry_name
  dockercfg             = module.odahuflow_prereqs.dockercfg

  model_output_web_ui_link  = module.odahuflow_prereqs.model_output_web_ui_link
  feedback_storage_link     = module.odahuflow_prereqs.feedback_storage_link
  model_output_region       = module.odahuflow_prereqs.model_output_region
  model_docker_web_ui_link  = module.odahuflow_prereqs.model_docker_web_ui_link
  model_output_secret       = module.odahuflow_prereqs.model_output_secret
  model_output_secret_key   = module.odahuflow_prereqs.model_output_secret_key
  data_bucket_region = module.odahuflow_prereqs.data_bucket_region

  docker_repo     = var.docker_repo
  docker_user     = var.docker_user
  docker_password = var.docker_password

  odahuflow_version            = var.odahuflow_version
  collector_region          = var.collector_region
  odahuflow_collector_iam_role = module.odahuflow_prereqs.odahuflow_collector_iam_role
  data_bucket        = var.data_bucket
  git_examples_key          = var.git_examples_key
  model_docker_url          = var.model_docker_url
  git_examples_uri          = var.git_examples_uri
  git_examples_reference    = var.git_examples_reference
  model_resources_cpu       = var.model_resources_cpu
  model_resources_mem       = var.model_resources_mem
  mlflow_toolchain_version  = var.mlflow_toolchain_version

  odahuflow_connection_decrypt_token = var.odahuflow_connection_decrypt_token

  jupyterlab_version = var.jupyterlab_version
  packager_version = var.packager_version
}

