locals {
  pg_credentials_plain = ((length(var.pgsql.secret_namespace) != 0) && (length(var.pgsql.secret_name) != 0)) ? 0 : 1

  pg_username = local.pg_credentials_plain == 1 ? var.pgsql.db_password : lookup(lookup(data.kubernetes_secret.pg[0], "data", {}), "username", "")
  pg_password = local.pg_credentials_plain == 1 ? var.pgsql.db_user : lookup(lookup(data.kubernetes_secret.pg[0], "data", {}), "password", "")

  ingress_auth_signin = format(
    "https://%s/oauth2/start?rd=https://$host$escaped_request_uri",
    var.cluster_domain
  )
  ingress_auth_url = "http://oauth2-proxy.kube-system.svc.cluster.local:4180/oauth2/auth"

  ingress_tls_enabled     = var.tls_secret_crt != "" && var.tls_secret_key != ""
  url_schema              = local.ingress_tls_enabled ? "https" : "http"
  ingress_tls_secret_name = "odahu-flow-tls"

  ingress_common = {
    enabled = true
  }
  
  ingress_web = {
    path  = "/argo"
    host  = var.cluster_domain
    hosts = [var.cluster_domain]

    annotations = {
      "kubernetes.io/ingress.class"                       = "nginx"
      "nginx.ingress.kubernetes.io/force-ssl-redirect"    = "true"
      "nginx.ingress.kubernetes.io/auth-signin"           = local.ingress_auth_signin
      "nginx.ingress.kubernetes.io/auth-url"              = local.ingress_auth_url
      "nginx.ingress.kubernetes.io/configuration-snippet" = <<-EOT
        set_escape_uri $escaped_request_uri $request_uri;
        auth_request_set $user   $upstream_http_x_auth_request_user;
        auth_request_set $email  $upstream_http_x_auth_request_email;
        auth_request_set $jwt    $upstream_http_x_auth_request_access_token;
        auth_request_set $_oauth2_proxy_1 $upstream_cookie__oauth2_proxy_1;

        proxy_set_header X-User        $user;
        proxy_set_header X-Email       $email;
        proxy_set_header X-JWT         $jwt;
        proxy_set_header Authorization "Bearer $jwt";

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
}

resource "kubernetes_namespace" "argo" {
  metadata {
    annotations = {
      name = var.namespace
    }
    name = var.namespace
  }
}

data "kubernetes_secret" "pg" {
  count = local.pg_credentials_plain == 0 ? 1 : 0
  metadata {
    name      = var.pgsql.secret_name
    namespace = var.pgsql.secret_namespace
  }
}

resource "kubernetes_secret" "postgres" {
#  count = var.configuration.enabled && var.pgsql.enabled ? 1 : 0

  metadata {
    name      = "argo-postgres"
    namespace = var.namespace
  }
  data = {
    "postgresql-login"    = local.pg_username
    "postgresql-password" = local.pg_password
  }
  type = "Opaque"

  depends_on = [kubernetes_namespace.argo]
}

resource "helm_release" "argo-workflows" {
  name          = "argo-workflows"
  repository    = var.helm_repo
  chart         = "argo"
  version       = var.argo_wf_helm_chart_version
  namespace     = var.namespace
  recreate_pods = true
#  timeout       = var.helm_timeout
  timeout       = 120
  values = [
    templatefile("${path.module}/templates/argo-workflows.yaml", {
      ingress        = yamlencode({
        server = {
          enabled = true,
          ingress = local.ingress_config
        }
      })
      pgsql_enabled  = var.pgsql.enabled
      pgsql_secret   = kubernetes_secret.postgres.metadata[0].name
      pgsql_username = "postgresql-login"
      pgsql_password = "postgresql-password"
      pgsql_host     = var.pgsql.db_host
      pgsql_dbname   = var.pgsql.db_name
    })
  ]
  depends_on    = [kubernetes_namespace.argo]
}

# resource "helm_release" "argo-events" {
#   name          = "argo-events"
#   repository    = var.helm_repo
#   chart         = "argo-events"
#   version       = var.argo_events_helm_chart_version
#   namespace     = var.namespace
#   recreate_pods = true
#   timeout       = var.helm_timeout
#   depends_on    = [kubernetes_namespace.argo]
# }
