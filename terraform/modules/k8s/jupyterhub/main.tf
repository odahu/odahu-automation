locals {
  ingress_tls_enabled     = var.tls_secret_crt != "" && var.tls_secret_key != ""
  url_schema              = local.ingress_tls_enabled ? "https" : "http"
  ingress_tls_secret_name = "jupyterhub-tls"

  jupyterhub_debug = "true"

  ingress_common = {
    enabled = true
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
    hosts = [var.cluster_domain]
  }

  ingress_tls = local.ingress_tls_enabled ? {
    tls = [
      { secretName = local.ingress_tls_secret_name, hosts = [var.cluster_domain] }
    ]
  } : {}

  ingress_config = merge(local.ingress_common, local.ingress_tls)

  culling_config = {
    enabled = var.jupyterhub_culling_enabled
    timeout = var.jupyterhub_culling_timeout
    every   = var.jupyterhub_culling_frequency
  }
}

resource "null_resource" "add_helm_jupyterhub_repository" {
  count = var.jupyterhub_enabled ? 1 : 0
  triggers = {
    build_number = timestamp()
  }
  provisioner "local-exec" {
    command = "helm repo add jupyterhub ${var.jupyterhub_helm_repo}"
  }
}

resource "random_string" "secret" {
  count       = var.jupyterhub_enabled ? 1 : 0
  length      = 64
  upper       = false
  lower       = true
  number      = true
  min_numeric = 32
  special     = false
}

resource "kubernetes_namespace" "jupyterhub" {
  count = var.jupyterhub_enabled ? 1 : 0
  metadata {
    annotations = {
      name = var.jupyterhub_namespace
    }
    labels = {
      project = "odahu-flow"
    }
    name = var.jupyterhub_namespace
  }
  depends_on = [null_resource.add_helm_jupyterhub_repository[0]]
}

module "docker_credentials" {
  source          = "../docker_auth"
  docker_repo     = var.docker_repo
  docker_username = var.docker_username
  docker_password = var.docker_password
  namespaces      = var.jupyterhub_enabled ? [kubernetes_namespace.jupyterhub[0].metadata[0].annotations.name] : []
}

resource "kubernetes_secret" "jupyterhub_tls" {
  count = var.jupyterhub_enabled && local.ingress_tls_enabled ? 1 : 0
  metadata {
    name      = local.ingress_tls_secret_name
    namespace = var.jupyterhub_namespace
  }
  data = {
    "tls.key" = var.tls_secret_key
    "tls.crt" = var.tls_secret_crt
  }
  type = "kubernetes.io/tls"

  depends_on = [kubernetes_namespace.jupyterhub[0]]
}

resource "helm_release" "jupyterhub" {
  count      = var.jupyterhub_enabled ? 1 : 0
  name       = "jupyterhub"
  chart      = "jupyterhub/jupyterhub"
  version    = var.jupyterhub_chart_version
  namespace  = var.jupyterhub_namespace
  repository = "jupyterhub"
  timeout    = var.helm_timeout

  values = [
    templatefile("${path.module}/templates/jupyterhub.yaml", {
      cluster_domain          = var.cluster_domain
      ingress_tls_secret_name = local.ingress_tls_secret_name
      jupyterhub_secret_token = var.jupyterhub_secret_token == "" ? random_string.secret[0].result : var.jupyterhub_secret_token
      debug_enabled           = local.jupyterhub_debug

      oauth_client_id       = var.oauth_client_id
      oauth_client_secret   = var.oauth_client_secret
      oauth_oidc_issuer_url = var.oauth_oidc_issuer_url

      ingress = yamlencode({ ingress = local.ingress_config })
      culling = yamlencode({ cull = local.culling_config })

      image_puller = var.jupyterhub_puller_enabled
      docker_tag   = var.docker_tag
      docker_repo  = var.docker_repo

      pgsql_enabled  = var.pgsql.enabled
      pgsql_password = var.pgsql.db_password
      pgsql_url = format(
        "postgres+psycopg2://%s@%s/%s",
        var.pgsql.db_user,
        var.pgsql.db_host,
        var.pgsql.db_name
      )
    })
  ]

  depends_on = [
    null_resource.add_helm_jupyterhub_repository[0],
    kubernetes_namespace.jupyterhub[0],
    kubernetes_secret.jupyterhub_tls[0]
  ]
}
