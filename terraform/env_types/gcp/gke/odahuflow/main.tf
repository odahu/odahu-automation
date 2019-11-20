########################################################
# Odahuflow setup
########################################################

module "odahuflow_prereqs" {
  source       = "../../../../modules/odahuflow/prereqs/gke"
  project_id   = var.project_id
  region       = var.region
  cluster_name = var.cluster_name
  data_bucket  = var.data_bucket
}

module "fluentd" {
  source = "../../../../modules/k8s/fluentd"

  docker_repo         = var.docker_repo
  odahu_infra_version = var.odahu_infra_version

  extra_helm_values = module.odahuflow_prereqs.fluent_helm_values
}

module "odahuflow_helm" {
  source = "../../../../modules/odahuflow/helm"

  tls_secret_crt = var.tls_crt
  tls_secret_key = var.tls_key
  cluster_domain = "odahu.${var.cluster_name}.${var.root_domain}"

  helm_repo                = var.helm_repo
  docker_repo              = var.docker_repo
  odahuflow_version        = var.odahuflow_version
  jupyterlab_version       = var.jupyterlab_version
  packager_version         = var.packager_version
  mlflow_toolchain_version = var.mlflow_toolchain_version

  odahuflow_connections              = concat(var.odahuflow_connections, module.odahuflow_prereqs.odahuflow_connections)
  extra_external_urls                = module.odahuflow_prereqs.extra_external_urls
  odahuflow_connection_decrypt_token = var.odahuflow_connection_decrypt_token
}
