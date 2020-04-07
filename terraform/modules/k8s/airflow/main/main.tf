locals {
  airflow_helm_version = "6.3.0"
  airflow_helm_repo    = "stable"
  debug_log_level      = "true"

  ingress_tls_enabled     = var.tls_secret_crt != "" && var.tls_secret_key != ""
  url_schema              = local.ingress_tls_enabled ? "https" : "http"
  ingress_tls_secret_name = "odahu-flow-tls"

  ingress_common = {
    enabled = true
  }

  ingress_web = {
    path  = "/airflow"
    host  = var.cluster_domain
    hosts = [var.cluster_domain]

    annotations = {
      "kubernetes.io/ingress.class"                       = "nginx"
      "nginx.ingress.kubernetes.io/force-ssl-redirect"    = "true"
      "nginx.ingress.kubernetes.io/auth-signin"           = format("https://%s/oauth2/start?rd=https://$host$escaped_request_uri", var.cluster_domain)
      "nginx.ingress.kubernetes.io/auth-url"              = "http://oauth2-proxy.kube-system.svc.cluster.local:4180/oauth2/auth"
      "nginx.ingress.kubernetes.io/configuration-snippet" = <<-EOT
          set_escape_uri $escaped_request_uri $request_uri;
          auth_request_set $user   $upstream_http_x_auth_request_user;
          auth_request_set $email  $upstream_http_x_auth_request_email;
          auth_request_set $jwt    $upstream_http_x_auth_request_access_token;
          auth_request_set $_oauth2_proxy_1 $upstream_cookie__oauth2_proxy_1;

          proxy_set_header X-User            $user;
          proxy_set_header X-Email           $email;
          proxy_set_header X-JWT             $jwt;
          proxy_set_header Authorization     "Bearer $jwt";

          access_by_lua_block {
            if ngx.var._oauth2_proxy_1 ~= "" then
                ngx.header["Set-Cookie"] = "_oauth2_proxy_1=" .. ngx.var._oauth2_proxy_1 .. ngx.var.auth_cookie:match("(; .*)")
            end
          }
        EOT
    }
  }

  ingress_tls = local.ingress_tls_enabled ? {
    tls = { enabled = true, secretName = local.ingress_tls_secret_name }
  } : {}

  ingress_config = merge(local.ingress_common, { web = merge(local.ingress_web, local.ingress_tls) })

  deploy_helm_timeout = "500"

  odahu_conn = {
    "auth_url"      = var.oauth_oidc_token_endpoint,
    "client_id"     = var.service_account.client_id,
    "client_secret" = var.service_account.client_secret,
    "scope"         = "openid profile offline_access groups"
  }

}

resource "kubernetes_namespace" "this" {
  metadata {
    annotations = {
      name = var.namespace
    }
    name = var.namespace
  }
}

resource "kubernetes_secret" "postgres" {
  count = var.configuration.enabled ? 1 : 0

  metadata {
    name      = "airflow-postgres"
    namespace = var.namespace
  }
  data = {
    "postgresql-password" = var.postgres_password
  }
  type       = "Opaque"
  depends_on = [kubernetes_namespace.this]
}

resource "kubernetes_secret" "airflow_tls" {
  count = var.configuration.enabled && local.ingress_tls_enabled ? 1 : 0
  metadata {
    name      = local.ingress_tls_secret_name
    namespace = var.namespace
  }
  data = {
    "tls.key" = var.tls_secret_key
    "tls.crt" = var.tls_secret_crt
  }
  type = "kubernetes.io/tls"

  depends_on = [kubernetes_namespace.this]
}

module "docker_credentials" {
  source          = "../../docker_auth"
  docker_repo     = var.docker_repo
  docker_username = var.docker_username
  docker_password = var.docker_password
  namespaces      = [kubernetes_namespace.this.metadata[0].annotations.name]
}

resource "helm_release" "airflow" {
  count      = var.configuration.enabled ? 1 : 0
  name       = "airflow"
  chart      = "airflow"
  version    = local.airflow_helm_version
  namespace  = var.namespace
  repository = local.airflow_helm_repo
  timeout    = local.deploy_helm_timeout

  values = [
    templatefile("${path.module}/templates/airflow.yaml", {
      airflow_variables            = jsonencode(var.airflow_variables)
      cluster_domain               = var.cluster_domain
      ingress                      = yamlencode({ ingress = local.ingress_config })
      docker_repo                  = var.docker_repo
      dag_repo                     = var.configuration.dag_repo
      dag_rev                      = var.examples_version
      fernet_key                   = var.configuration.fernet_key
      wine_conn                    = jsonencode(var.wine_connection)
      log_storage_size             = var.configuration.log_storage_size
      namespace                    = var.namespace
      odahu_conn                   = jsonencode(local.odahu_conn)
      odahu_airflow_plugin_version = var.odahu_airflow_plugin_version
      storage_size                 = var.configuration.storage_size
    }),
  ]

  depends_on = [kubernetes_namespace.this, kubernetes_secret.postgres]
}
