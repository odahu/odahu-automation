########################################################
# K8S setup
########################################################

module "irsa" {
  source       = "../../../../modules/aws/irsa"
  cluster_name = var.cluster_name
}

module "cluster_autoscaler" {
  source = "../../../../modules/k8s/cluster_autoscaler"

  aws_region         = var.aws_region
  iam_role_arn       = module.irsa.autoscaler_role_arn
  cluster_name       = var.cluster_name
  cpu_max_limit      = var.cluster_autoscaling_cpu_max_limit
  mem_max_limit      = var.cluster_autoscaling_memory_max_limit
  autoscaler_version = var.autoscaler_version

  depends_on = [module.irsa]
}

module "nginx_ingress_tls" {
  source         = "../../../../modules/k8s/nginx-ingress/tls"
  cluster_name   = var.cluster_name
  tls_secret_key = var.tls_key
  tls_secret_crt = var.tls_crt
}

module "nginx_ingress_prereqs" {
  source       = "../../../../modules/k8s/nginx-ingress/prereqs/eks"
  cluster_name = var.cluster_name
}

module "nginx_ingress_helm" {
  source      = "../../../../modules/k8s/nginx-ingress/helm"
  helm_values = module.nginx_ingress_prereqs.helm_values

  depends_on = [module.nginx_ingress_prereqs]
}

module "auth" {
  source                = "../../../../modules/k8s/auth"
  domain_name           = var.domain
  oauth_client_id       = var.oauth_client_id
  oauth_client_secret   = var.oauth_client_secret
  oauth_oidc_issuer_url = var.oauth_oidc_issuer_url
  oauth_oidc_audience   = var.oauth_oidc_audience
  oauth_oidc_scope      = var.oauth_oidc_scope
  oauth_cookie_expire   = "168h0m0s"
  oauth_cookie_secret   = var.oauth_cookie_secret

  depends_on = [module.cluster_autoscaler]
}

module "monitoring" {
  source               = "../../../../modules/k8s/monitoring"
  cluster_domain       = var.domain
  helm_timeout         = 25 * 60
  grafana_admin        = var.grafana_admin
  grafana_pass         = var.grafana_pass
  tls_secret_key       = var.tls_key
  tls_secret_crt       = var.tls_crt
  monitoring_namespace = var.monitoring_namespace
  db_namespace         = var.db_namespace

  pgsql_grafana = {
    enabled          = var.postgres.enabled
    db_host          = module.postgresql.pgsql_endpoint
    db_name          = "grafana"
    db_user          = ""
    db_password      = ""
    secret_namespace = module.postgresql.pgsql_credentials["grafana"].namespace
    secret_name      = module.postgresql.pgsql_credentials["grafana"].secret
  }

  depends_on = [module.postgresql]
}

module "istio" {
  source          = "../../../../modules/k8s/istio"
  tls_secret_key  = var.tls_key
  tls_secret_crt  = var.tls_crt
  docker_repo     = var.docker_repo
  docker_username = var.docker_username
  docker_password = var.docker_password

  depends_on = [module.cluster_autoscaler]
}

module "knative" {
  source              = "../../../../modules/k8s/knative"
  helm_repo           = var.helm_repo
  odahu_infra_version = var.odahu_infra_version
  helm_timeout        = 600
  depends_on          = [module.istio]
}

module "tekton" {
  source              = "../../../../modules/k8s/tekton"
  helm_repo           = var.helm_repo
  odahu_infra_version = var.odahu_infra_version

  depends_on = [module.cluster_autoscaler]
}

module "nfs" {
  source = "../../../../modules/k8s/nfs"

  configuration = var.nfs

  depends_on = [module.cluster_autoscaler]
}

#########################################################
## DNS setup
#########################################################

module "odahu-dns" {
  source = "../../../../modules/dns/modules/gcp"

  domain       = var.domain
  managed_zone = var.managed_zone
  records      = var.records

  lb_record = {
    "name"  = regex("^[^.]*", var.domain)
    "value" = local.is_lb_an_ip ? module.nginx_ingress_prereqs.load_balancer_ip : "${module.nginx_ingress_prereqs.load_balancer_ip}."
    "type"  = local.is_lb_an_ip ? "A" : "CNAME"
    "ttl"   = var.lb_record.ttl
  }

  depends_on = [module.nginx_ingress_prereqs]
}

########################################################
# ODAHU flow setup
########################################################
module "postgresql" {
  source = "../../../../modules/k8s/postgresql"

  configuration = var.postgres
  databases     = local.databases

  depends_on = [
    module.cluster_autoscaler,
    module.nfs
  ]
}

module "pg_backup_prereqs" {
  source = "../../../../modules/k8s/postgresql-backup/prereqs/eks"

  backup_settings = var.backup_settings
  cluster_name    = var.cluster_name

  depends_on = [module.postgresql]
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

  depends_on = [module.pg_backup_prereqs]
}

module "odahuflow_prereqs" {
  source                  = "../../../../modules/odahuflow/prereqs/eks"
  region                  = var.aws_region
  cluster_name            = var.cluster_name
  kms_key_arn             = var.kms_key_arn
  data_bucket             = var.data_bucket
  log_bucket              = var.log_bucket
  log_expiration_days     = var.log_expiration_days
  openid_connect_provider = module.irsa.openid_connect_provider
  collector_sa_list = [
    "system:serviceaccount:${var.logging_namespace}:fluentd-daemonset",
    "system:serviceaccount:${var.fluentd_namespace}:fluentd",
    "system:serviceaccount:${var.elk_namespace}:logstash"
  ]
  jupyter_notebook_sa_list = ["system:serviceaccount:jupyterhub:notebook"]
}

module "airflow_prereqs" {
  source = "../../../../modules/k8s/airflow/prereqs/eks"

  wine_bucket             = module.odahuflow_prereqs.odahu_data_bucket_name
  cluster_name            = var.cluster_name
  syncer_sa_list          = ["system:serviceaccount:${var.airflow_namespace}:odahu-syncer"]
  dag_bucket              = local.dag_bucket
  dag_bucket_path         = local.dag_bucket_path
  region                  = var.aws_region
  kms_key_arn             = var.kms_key_arn
  openid_connect_provider = module.irsa.openid_connect_provider

  depends_on = [module.odahuflow_prereqs]
}

module "airflow" {
  source = "../../../../modules/k8s/airflow/main"

  namespace                    = var.airflow_namespace
  configuration                = var.airflow
  cluster_name                 = var.cluster_name
  cluster_domain               = var.domain
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
    enabled          = var.postgres.enabled
    db_host          = module.postgresql.pgsql_endpoint
    db_name          = "airflow"
    db_user          = ""
    db_password      = ""
    secret_namespace = module.postgresql.pgsql_credentials["airflow"].namespace
    secret_name      = module.postgresql.pgsql_credentials["airflow"].secret
  }

  depends_on = [module.airflow_prereqs, module.postgresql]
}

module "storage-syncer" {
  source = "../../../../modules/k8s/syncer"

  namespace           = var.airflow_namespace
  helm_repo           = var.helm_repo
  extra_helm_values   = module.airflow_prereqs.syncer_helm_values
  odahu_infra_version = var.odahu_infra_version

  depends_on = [module.airflow]
}

module "fluentd" {
  source = "../../../../modules/k8s/fluentd"

  namespace           = var.fluentd_namespace
  docker_repo         = var.docker_repo
  docker_username     = var.docker_username
  docker_password     = var.docker_password
  odahu_infra_version = var.odahu_infra_version
  helm_repo           = var.helm_repo
  extra_helm_values   = module.odahuflow_prereqs.fluent_helm_values

  depends_on = [module.irsa, module.odahuflow_prereqs]
}

module "fluentd-daemonset" {
  source = "../../../../modules/k8s/fluentd-daemonset"

  namespace           = var.logging_namespace
  docker_repo         = var.docker_repo
  docker_username     = var.docker_username
  docker_password     = var.docker_password
  odahu_infra_version = var.odahu_infra_version
  helm_repo           = var.helm_repo
  extra_helm_values   = module.odahuflow_prereqs.fluent_daemonset_helm_values

  depends_on = [module.irsa, module.odahuflow_prereqs]
}

module "jupyterhub" {
  source = "../../../../modules/k8s/jupyterhub"

  jupyterhub_enabled      = var.jupyterhub_enabled
  notebook_sa_annotations = module.odahuflow_prereqs.jupyter_notebook_sa_annotations

  cluster_domain = var.domain
  tls_secret_crt = var.tls_crt
  tls_secret_key = var.tls_key

  docker_tag      = var.jupyterlab_version
  docker_repo     = var.docker_repo
  docker_username = var.docker_username
  docker_password = var.docker_password

  oauth_client_id       = var.oauth_client_id
  oauth_client_secret   = var.oauth_client_secret
  oauth_oidc_issuer_url = var.oauth_oidc_issuer_url

  pgsql = {
    enabled          = var.postgres.enabled
    db_host          = module.postgresql.pgsql_endpoint
    db_name          = "jupyterhub"
    db_user          = ""
    db_password      = ""
    secret_namespace = module.postgresql.pgsql_credentials["jupyterhub"].namespace
    secret_name      = module.postgresql.pgsql_credentials["jupyterhub"].secret
  }

  depends_on = [module.postgresql, module.odahuflow_prereqs]
}

module "vault" {
  source        = "../../../../modules/k8s/vault"
  configuration = var.vault

  pgsql = {
    enabled          = var.postgres.enabled
    db_host          = module.postgresql.pgsql_endpoint
    db_name          = "vault"
    db_user          = ""
    db_password      = ""
    secret_namespace = module.postgresql.pgsql_credentials["vault"].namespace
    secret_name      = module.postgresql.pgsql_credentials["vault"].secret
  }

  depends_on = [module.irsa, module.postgresql]
}

module "elasticsearch" {
  source                = "../../../../modules/k8s/elk"
  cluster_domain        = var.domain
  namespace             = var.elk_namespace
  tls_secret_key        = var.tls_key
  tls_secret_crt        = var.tls_crt
  docker_repo           = var.docker_repo
  docker_username       = var.docker_username
  docker_password       = var.docker_password
  logstash_input_config = module.odahuflow_prereqs.logstash_input_config
  logstash_annotations  = module.odahuflow_prereqs.logstash_annotations
  odahu_infra_version   = var.odahu_infra_version
  odahu_helm_repo       = var.helm_repo

  depends_on = [
    module.nginx_ingress_helm,
    module.irsa,
    module.cluster_autoscaler,
    module.odahuflow_prereqs
  ]
}

module "odahuflow_helm" {
  source = "../../../../modules/odahuflow/helm"

  tls_secret_crt = var.tls_crt
  tls_secret_key = var.tls_key
  cluster_domain = var.domain

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
    enabled          = var.postgres.enabled
    db_host          = module.postgresql.pgsql_endpoint
    db_name          = var.odahu_database
    db_user          = ""
    db_password      = ""
    secret_namespace = module.postgresql.pgsql_credentials[var.odahu_database].namespace
    secret_name      = module.postgresql.pgsql_credentials[var.odahu_database].secret
  }
  pgsql_mlflow = {
    enabled          = var.postgres.enabled
    db_host          = module.postgresql.pgsql_endpoint
    db_name          = "mlflow"
    db_user          = ""
    db_password      = ""
    secret_namespace = module.postgresql.pgsql_credentials["mlflow"].namespace
    secret_name      = module.postgresql.pgsql_credentials["mlflow"].secret
  }

  depends_on = [module.nginx_ingress_helm, module.auth, module.postgresql, module.odahuflow_prereqs, module.vault, module.knative]
}
