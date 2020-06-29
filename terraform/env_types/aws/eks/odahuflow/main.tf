module "postgresql" {
  source        = "../../../../modules/k8s/postgresql"
  configuration = var.postgres
  databases = [
    "airflow",
    "mlflow",
    "jupyterhub",
    var.odahu_database
  ]
}

module "odahuflow_prereqs" {
  source       = "../../../../modules/odahuflow/prereqs/eks"
  region       = var.aws_region
  cluster_name = var.cluster_name
  data_bucket  = var.data_bucket
}

module "airflow_prereqs" {
  source = "../../../../modules/k8s/airflow/prereqs/eks"

  wine_bucket     = module.odahuflow_prereqs.odahu_bucket_name
  cluster_name    = var.cluster_name
  dag_bucket      = local.dag_bucket
  dag_bucket_path = local.dag_bucket_path
  region          = var.aws_region
}

module "airflow" {
  source = "../../../../modules/k8s/airflow/main"

  configuration                = var.airflow
  cluster_name                 = var.cluster_name
  cluster_domain               = var.cluster_domain_name
  oauth_oidc_token_endpoint    = var.oauth_oidc_token_endpoint
  airflow_variables            = {}
  examples_version             = var.examples_version
  wine_connection              = {}
  service_account              = var.service_accounts.airflow
  docker_repo                  = var.docker_repo
  docker_username              = var.docker_username
  docker_password              = var.docker_password
  odahu_airflow_plugin_version = var.odahu_airflow_plugin_version
  tls_secret_crt               = var.tls_crt
  tls_secret_key               = var.tls_key

  pgsql = {
    enabled     = var.postgres.enabled
    db_host     = module.postgresql.pgsql_endpoint
    db_name     = "airflow"
    db_user     = module.postgresql.pgsql_credentials["airflow"].username
    db_password = module.postgresql.pgsql_credentials["airflow"].password
  }
}

module "storage-syncer" {
  source = "../../../../modules/k8s/syncer"

  namespace           = "airflow"
  extra_helm_values   = module.airflow_prereqs.syncer_helm_values
  odahu_infra_version = var.odahu_infra_version
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

module "jupyterhub" {
  source = "../../../../modules/k8s/jupyterhub"

  jupyterhub_enabled = var.jupyterhub_enabled
  cluster_domain     = var.cluster_domain_name
  tls_secret_crt     = var.tls_crt
  tls_secret_key     = var.tls_key

  docker_tag      = var.jupyterlab_version
  docker_repo     = var.docker_repo
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
  logstash_input_config = module.odahuflow_prereqs.logstash_input_config
  logstash_annotations  = module.odahuflow_prereqs.logstash_annotations
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

  odahuflow_training_timeout = var.odahuflow_training_timeout

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

  resource_uploader_sa        = var.service_accounts.resource_uploader
  operator_sa                 = var.service_accounts.operator
  oauth_oidc_token_endpoint   = var.oauth_oidc_token_endpoint
  oauth_oidc_signout_endpoint = var.oauth_oidc_signout_endpoint
  oauth_oidc_issuer_url       = var.oauth_oidc_issuer_url
  oauth_mesh_enabled          = var.oauth_mesh_enabled
  vault_enabled               = var.vault.enabled
  airflow_enabled             = var.airflow.enabled
  pgsql = {
    enabled     = var.postgres.enabled
    db_host     = module.postgresql.pgsql_endpoint
    db_name     = var.odahu_database
    db_user     = module.postgresql.pgsql_credentials[var.odahu_database].username
    db_password = module.postgresql.pgsql_credentials[var.odahu_database].password
  }
  node_selector_webhook_version = var.node_selector_webhook_version
  node_selector_webhook_settings = var.node_selector_webhook_settings
}
