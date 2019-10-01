########################################################
# Legion setup
########################################################
module "legion" {
  source                      = "../../../../modules/legion"
  region                      = var.region
  project_id                  = var.project_id
  legion_helm_repo            = var.legion_helm_repo
  root_domain                 = var.root_domain
  cluster_name                = var.cluster_name
  docker_repo                 = var.docker_repo
  docker_user                 = var.docker_user
  docker_password             = var.docker_password
  legion_version              = var.legion_version
  collector_region            = var.collector_region
  legion_data_bucket          = var.legion_data_bucket
  git_examples_key            = var.git_examples_key
  model_docker_url            = var.model_docker_url
  git_examples_uri            = var.git_examples_uri
  git_examples_reference      = var.git_examples_reference
  model_resources_cpu         = var.model_resources_cpu
  model_resources_mem         = var.model_resources_mem
  mlflow_toolchain_version    = var.mlflow_toolchain_version
  git_examples_description    = var.git_examples_description
  git_examples_web_ui_link    = var.git_examples_web_ui_link
  model_authorization_enabled = true
  model_oidc_jwks_url         = "${var.keycloak_url}/auth/realms/${var.keycloak_realm}/protocol/openid-connect/certs"
  model_oidc_issuer           = "${var.keycloak_url}/auth/realms/${var.keycloak_realm}"
  tls_secret_key              = var.tls_key
  tls_secret_crt              = var.tls_crt
}
