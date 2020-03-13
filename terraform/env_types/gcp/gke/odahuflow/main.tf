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

module "nfs" {
  source = "../../../../modules/k8s/nfs"

  configuration = var.nfs
}

module "airflow" {
  source = "../../../../modules/k8s/airflow"

  nfs_dependency            = module.nfs.helm_chart
  configuration             = var.airflow
  cluster_name              = var.cluster_name
  postgres_password         = var.postgres_password
  domain                    = var.dns.domain
  project_id                = var.project_id
  oauth_oidc_token_endpoint = var.oauth_oidc_token_endpoint
  service_account           = var.service_accounts.airflow
  wine_bucket               = module.odahuflow_prereqs.odahu_bucket_name
  wine_data_url             = var.wine_data_url
  examples_version          = var.odahuflow_connections[0].spec.reference
  docker_repo               = var.docker_repo
  docker_username           = var.docker_username
  docker_password           = var.docker_password
}

module "fluentd" {
  source = "../../../../modules/k8s/fluentd"

  docker_repo         = var.docker_repo
  docker_username     = var.docker_username
  docker_password     = var.docker_password
  odahu_infra_version = var.odahu_infra_version

  extra_helm_values = module.odahuflow_prereqs.fluent_helm_values
}

module "jupyterhub" {
  source = "../../../../modules/k8s/jupyterhub"

  jupyterhub_enabled = var.jupyterhub_enabled
  cluster_domain     = var.cluster_domain_name
  tls_secret_crt     = var.tls_crt
  tls_secret_key     = var.tls_key

  docker_repo     = var.docker_repo
  docker_tag      = var.jupyterlab_version
  docker_username = var.docker_username
  docker_password = var.docker_password

  oauth_client_id       = var.oauth_client_id
  oauth_client_secret   = var.oauth_client_secret
  oauth_oidc_issuer_url = var.oauth_oidc_issuer_url
}

module "odahuflow_helm" {
  source = "../../../../modules/odahuflow/helm"

  tls_secret_crt = var.tls_crt
  tls_secret_key = var.tls_key
  cluster_domain = var.cluster_domain_name

  helm_repo                = var.helm_repo
  docker_repo              = var.docker_repo
  docker_username          = var.docker_username
  docker_password          = var.docker_password
  odahuflow_version        = var.odahuflow_version
  packager_version         = var.packager_version
  mlflow_toolchain_version = var.mlflow_toolchain_version
  odahu_ui_version         = var.odahu_ui_version

  node_pools = var.node_pools

  odahuflow_connections              = concat(var.odahuflow_connections, module.odahuflow_prereqs.odahuflow_connections)
  extra_external_urls                = concat(module.jupyterhub.external_url, module.odahuflow_prereqs.extra_external_urls)
  odahuflow_connection_decrypt_token = var.odahuflow_connection_decrypt_token
  resource_uploader_sa               = var.service_accounts.resource_uploader
  operator_sa                        = var.service_accounts.operator
  oauth_oidc_token_endpoint          = var.oauth_oidc_token_endpoint
  oauth_oidc_issuer_url              = var.oauth_oidc_issuer_url
  oauth_mesh_enabled                 = var.oauth_mesh_enabled
  vault_enabled                      = var.vault.enabled
}
