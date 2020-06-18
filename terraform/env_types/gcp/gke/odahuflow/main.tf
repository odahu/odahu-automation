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

module "airflow_prereqs" {
  source = "../../../../modules/k8s/airflow/prereqs/gke"

  project_id      = var.project_id
  wine_bucket     = module.odahuflow_prereqs.odahu_bucket_name
  cluster_name    = var.cluster_name
  dag_bucket      = local.dag_bucket
  dag_bucket_path = local.dag_bucket_path
  region          = var.region
}

module "airflow_test_data" {
  source = "../../../../modules/k8s/airflow/test_data/gke"

  wine_bucket      = module.odahuflow_prereqs.odahu_bucket_name
  examples_version = var.examples_version
  wine_data_url    = var.wine_data_url
}

module "airflow" {
  source = "../../../../modules/k8s/airflow/main"

  configuration                = var.airflow
  cluster_name                 = var.cluster_name
  cluster_domain               = var.cluster_domain_name
  airflow_variables            = module.airflow_prereqs.airflow_variables
  examples_version             = var.examples_version
  oauth_oidc_token_endpoint    = var.oauth_oidc_token_endpoint
  wine_connection              = module.airflow_prereqs.wine_connection
  service_account              = var.service_accounts.airflow
  docker_repo                  = var.docker_repo
  docker_username              = var.docker_username
  docker_password              = var.docker_password
  odahu_airflow_plugin_version = var.odahu_airflow_plugin_version
  tls_secret_crt               = var.tls_crt
  tls_secret_key               = var.tls_key
}

module "fluentd" {
  source = "../../../../modules/k8s/fluentd"

  docker_repo         = var.docker_repo
  docker_username     = var.docker_username
  docker_password     = var.docker_password
  odahu_infra_version = var.odahu_infra_version

  extra_helm_values = module.odahuflow_prereqs.fluent_helm_values
}

module "fluentd-daemonset" {
  source = "../../../../modules/k8s/fluentd-daemonset"

  docker_repo         = var.docker_repo
  docker_username     = var.docker_username
  docker_password     = var.docker_password
  odahu_infra_version = var.odahu_infra_version

  extra_helm_values = module.odahuflow_prereqs.fluent_daemonset_helm_values
}

module "storage-syncer" {
  source = "../../../../modules/k8s/syncer"

  namespace           = "airflow"
  extra_helm_values   = module.airflow_prereqs.syncer_helm_values
  odahu_infra_version = var.odahu_infra_version
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

module "elasticsearch" {
  source                = "../../../../modules/k8s/elk"
  cluster_domain        = var.cluster_domain_name
  tls_secret_key        = var.tls_key
  tls_secret_crt        = var.tls_crt
  docker_repo           = var.docker_repo
  docker_username       = var.docker_username
  docker_password       = var.docker_password
  sa_key                = module.odahuflow_prereqs.odahu_collector_sa_key
  cloud_type            = "gcp"
  logstash_input_config = module.odahuflow_prereqs.logstash_input_config
  odahu_infra_version   = var.odahu_infra_version
  odahu_helm_repo       = var.helm_repo
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

  odahuflow_connections = concat(
    var.odahuflow_connections,
    module.odahuflow_prereqs.odahuflow_connections
  )

  extra_external_urls = concat(
    module.jupyterhub.external_url,
    module.airflow.external_url,
    module.elasticsearch.external_url,
    module.odahuflow_prereqs.extra_external_urls
  )

  odahuflow_training_timeout  = var.odahuflow_training_timeout
  resource_uploader_sa        = var.service_accounts.resource_uploader
  operator_sa                 = var.service_accounts.operator
  oauth_oidc_token_endpoint   = var.oauth_oidc_token_endpoint
  oauth_oidc_signout_endpoint = var.oauth_oidc_signout_endpoint
  oauth_oidc_issuer_url       = var.oauth_oidc_issuer_url
  oauth_mesh_enabled          = var.oauth_mesh_enabled
  vault_enabled               = var.vault.enabled
  airflow_enabled             = var.airflow.enabled
  db = {
    enabled      = var.postgres.enabled
    db_name      = var.odahu_database
    cluster_name = var.postgres.cluster_name
  }

}
