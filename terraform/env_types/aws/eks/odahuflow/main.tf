########################################################
# Odahuflow setup
########################################################
module "odahuflow_prereqs" {
  source       = "../../../../modules/odahuflow/prereqs/eks"
  region       = var.aws_region
  cluster_name = var.cluster_name
  data_bucket  = var.data_bucket
}

module "fluentd" {
  source = "../../../../modules/k8s/fluentd"

  docker_repo         = var.docker_repo
  odahu_infra_version = var.odahu_infra_version

  extra_helm_values = module.odahuflow_prereqs.fluent_helm_values
}

module "jupyterhub" {
  source = "../../../../modules/k8s/jupyterhub"

  jupyterhub_enabled = var.jupyterhub_enabled
  cluster_domain     = "odahu.${var.cluster_name}.${var.root_domain}"
  tls_secret_crt     = var.tls_crt
  tls_secret_key     = var.tls_key

  docker_repo = var.docker_repo
  docker_tag  = var.jupyterlab_version

  oauth_client_id       = var.oauth_client_id
  oauth_client_secret   = var.oauth_client_secret
  oauth_oidc_issuer_url = var.oauth_oidc_issuer_url
}

module "odahuflow_helm" {
  source = "../../../../modules/odahuflow/helm"

  tls_secret_crt = var.tls_crt
  tls_secret_key = var.tls_key
  cluster_domain = "odahu.${var.cluster_name}.${var.root_domain}"

  helm_repo                = var.helm_repo
  docker_repo              = var.docker_repo
  odahuflow_version        = var.odahuflow_version
  packager_version         = var.packager_version
  mlflow_toolchain_version = var.mlflow_toolchain_version

  odahuflow_connections              = concat(var.odahuflow_connections, module.odahuflow_prereqs.odahuflow_connections)
  extra_external_urls                = concat(module.jupyterhub.external_url, module.odahuflow_prereqs.extra_external_urls)
  odahuflow_connection_decrypt_token = var.odahuflow_connection_decrypt_token
}
