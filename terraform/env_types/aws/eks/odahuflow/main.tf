module "postgresql" {
  source = "../../../../modules/k8s/postgresql"

  configuration = var.postgres
  databases     = local.databases
}

module "pg_backup_prereqs" {
  source = "../../../../modules/k8s/postgresql-backup/prereqs/eks"

  backup_settings = var.backup_settings
  cluster_name    = var.cluster_name
}

module "pg_backup" {
  source = "../../../../modules/k8s/postgresql-backup/main"

  backup_settings   = var.backup_settings
  backup_job_config = module.pg_backup_prereqs.backup_job_config

  pg_endpoint     = module.postgresql.pgsql_endpoint
  pg_databases    = local.databases
  docker_repo     = var.docker_repo
  docker_tag      = var.odahu_automation_version
  docker_username = var.docker_username
  docker_password = var.docker_password
}

module "odahuflow_prereqs" {
  source              = "../../../../modules/odahuflow/prereqs/eks"
  region              = var.aws_region
  cluster_name        = var.cluster_name
  data_bucket         = var.data_bucket
  log_bucket          = var.log_bucket
  log_expiration_days = var.log_expiration_days
}

module "airflow_prereqs" {
  source = "../../../../modules/k8s/airflow/prereqs/eks"

  wine_bucket     = module.odahuflow_prereqs.odahu_data_bucket_name
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
  helm_repo           = var.helm_repo
  extra_helm_values   = module.airflow_prereqs.syncer_helm_values
  odahu_infra_version = var.odahu_infra_version
}

module "fluentd" {
  source = "../../../../modules/k8s/fluentd"

  docker_repo         = var.docker_repo
  docker_username     = var.docker_username
  docker_password     = var.docker_password
  odahu_infra_version = var.odahu_infra_version

  helm_repo         = var.helm_repo
  extra_helm_values = module.odahuflow_prereqs.fluent_helm_values
}

module "fluentd-daemonset" {
  source = "../../../../modules/k8s/fluentd-daemonset"

  docker_repo         = var.docker_repo
  docker_username     = var.docker_username
  docker_password     = var.docker_password
  odahu_infra_version = var.odahu_infra_version

  helm_repo         = var.helm_repo
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

  pgsql = {
    enabled     = var.postgres.enabled
    db_host     = module.postgresql.pgsql_endpoint
    db_name     = "jupyterhub"
    db_user     = module.postgresql.pgsql_credentials["jupyterhub"].username
    db_password = module.postgresql.pgsql_credentials["jupyterhub"].password
  }
}

module "vault" {
  source        = "../../../../modules/k8s/vault"
  configuration = var.vault
  pgsql = {
    enabled     = var.postgres.enabled
    db_host     = module.postgresql.pgsql_endpoint
    db_name     = "vault"
    db_user     = module.postgresql.pgsql_credentials["vault"].username
    db_password = module.postgresql.pgsql_credentials["vault"].password
  }
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
  service_catalog_sa          = var.service_accounts.service_catalog
  oauth_oidc_token_endpoint   = var.oauth_oidc_token_endpoint
  oauth_oidc_signout_endpoint = var.oauth_oidc_signout_endpoint
  oauth_oidc_issuer_url       = var.oauth_oidc_issuer_url
  opa_chart_version           = var.odahu_infra_version
  opa                         = var.opa
  oauth_mesh_enabled          = var.opa.authn.enabled
  vault_enabled               = var.vault.enabled
  vault_namespace             = module.vault.namespace
  vault_tls_secret_name       = module.vault.tls_secret
  airflow_enabled             = var.airflow.enabled
  pgsql_odahu = {
    enabled     = var.postgres.enabled
    db_host     = module.postgresql.pgsql_endpoint
    db_name     = var.odahu_database
    db_user     = module.postgresql.pgsql_credentials[var.odahu_database].username
    db_password = module.postgresql.pgsql_credentials[var.odahu_database].password
  }
  pgsql_mlflow = {
    enabled     = var.postgres.enabled
    db_host     = module.postgresql.pgsql_endpoint
    db_name     = var.odahu_database
    db_user     = module.postgresql.pgsql_credentials["mlflow"].username
    db_password = module.postgresql.pgsql_credentials["mlflow"].password
  }
}
