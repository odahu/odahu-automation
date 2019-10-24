########################################################
# Legion setup
########################################################
########################################################
# Legion setup
########################################################
module "legion_prereqs" {
  source             = "../../../../modules/legion_gke"
  project_id         = var.project_id
  region             = var.region
  cluster_name       = var.cluster_name
  legion_data_bucket = var.legion_data_bucket
}

module "legion" {
  source         = "../../../../modules/legion"
  tls_secret_crt = var.tls_crt
  tls_secret_key = var.tls_key
  root_domain    = var.root_domain
  cluster_name   = var.cluster_name
  cluster_type   = var.cluster_type
  cloud_type     = var.cloud_type

  legion_version     = var.legion_version
  legion_helm_repo   = var.legion_helm_repo

  region               = var.region
  project_id           = var.project_id

  bucket_registry_name  = module.legion_prereqs.bucket_registry_name

  model_docker_user        = module.legion_prereqs.model_docker_user
  model_docker_repo        = module.legion_prereqs.model_docker_repo
  model_docker_password    = module.legion_prereqs.model_docker_password
  model_docker_url         = var.model_docker_url
  model_docker_web_ui_link = module.legion_prereqs.model_docker_web_ui_link

  model_output_bucket      = module.legion_prereqs.model_output_bucket
  model_output_secret      = module.legion_prereqs.model_output_secret
  model_output_web_ui_link = module.legion_prereqs.model_output_web_ui_link
  model_output_region      = module.legion_prereqs.model_output_region

  collector_region         = ""
  legion_collector_sa      = module.legion_prereqs.legion_collector_sa
  legion_data_bucket       = var.legion_data_bucket

  dockercfg       = module.legion_prereqs.dockercfg
  docker_repo     = var.docker_repo
  docker_user     = var.docker_user
  docker_password = var.docker_password

  feedback_storage_link = module.legion_prereqs.feedback_storage_link

  git_examples_key         = var.git_examples_key
  git_examples_uri         = var.git_examples_uri
  git_examples_reference   = var.git_examples_reference

  model_resources_cpu      = var.model_resources_cpu
  model_resources_mem      = var.model_resources_mem
  mlflow_toolchain_version = var.mlflow_toolchain_version
}
