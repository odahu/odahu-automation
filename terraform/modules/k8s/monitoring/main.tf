locals {
  grafana_pg_credentials_plain = ((length(var.pgsql.secret_namespace) != 0) && (length(var.pgsql.secret_name) != 0)) ? 0 : 1

  grafana_pg_username = local.grafana_pg_credentials_plain == 1 ? var.pgsql.db_password : lookup(lookup(data.kubernetes_secret.pg[0], "data", {}), "username", "")
  grafana_pg_password = local.grafana_pg_credentials_plain == 1 ? var.pgsql.db_user : lookup(lookup(data.kubernetes_secret.pg[0], "data", {}), "password", "")

  ingress_tls_secret_name = "odahu-flow-tls"

  ingress_auth_signin = format(
    "https://%s/oauth2/start?rd=https://$host$escaped_request_uri",
    var.cluster_domain
  )
  ingress_auth_url = "http://oauth2-proxy.kube-system.svc.cluster.local:4180/oauth2/auth"

  ingress_nginx_annotations = {
    "kubernetes.io/ingress.class"                       = "nginx"
    "nginx.ingress.kubernetes.io/force-ssl-redirect"    = "true"
    "nginx.ingress.kubernetes.io/auth-signin"           = local.ingress_auth_signin
    "nginx.ingress.kubernetes.io/auth-url"              = local.ingress_auth_url
    "nginx.ingress.kubernetes.io/configuration-snippet" = <<-EOT
      rewrite          ^\/[\w-]+(\/|$)(.*) /$2 break;
      set_escape_uri   $escaped_request_uri $request_uri;
      auth_request_set $user   $upstream_http_x_auth_request_user;
      auth_request_set $email  $upstream_http_x_auth_request_email;
      auth_request_set $jwt    $upstream_http_x_auth_request_access_token;
      auth_request_set $_oauth2_proxy_1 $upstream_cookie__oauth2_proxy_1;

      proxy_set_header X-User        $user;
      proxy_set_header X-Email       $email;
      proxy_set_header X-JWT         $jwt;
      proxy_set_header Authorization "";

      access_by_lua_block {
        if ngx.var._oauth2_proxy_1 ~= "" then
          ngx.header["Set-Cookie"] = "_oauth2_proxy_1=" .. ngx.var._oauth2_proxy_1 .. ngx.var.auth_cookie:match("(; .*)")
        end
      }
    EOT
  }
}

########################################################
# Prometheus monitoring
########################################################
data "kubernetes_secret" "pg" {
  count = local.grafana_pg_credentials_plain == 0 ? 1 : 0
  metadata {
    name      = var.pgsql.secret_name
    namespace = var.pgsql.secret_namespace
  }
}

resource "kubernetes_namespace" "monitoring" {
  metadata {
    annotations = {
      name = var.monitoring_namespace
    }
    labels = {
      project       = "odahuflow"
      k8s-component = "monitoring"
    }
    name = var.monitoring_namespace
  }
  timeouts {
    delete = "15m"
  }
}

resource "kubernetes_secret" "tls_monitoring" {
  metadata {
    name      = local.ingress_tls_secret_name
    namespace = kubernetes_namespace.monitoring.metadata[0].annotations.name
  }
  data = {
    "tls.key" = var.tls_secret_key
    "tls.crt" = var.tls_secret_crt
  }
  type = "kubernetes.io/tls"
}

resource "helm_release" "monitoring" {
  name       = "monitoring"
  chart      = "odahu-flow-monitoring"
  version    = var.odahu_infra_version
  namespace  = kubernetes_namespace.monitoring.metadata[0].annotations.name
  repository = var.helm_repo
  timeout    = var.helm_timeout

  values = [
    templatefile("${path.module}/templates/monitoring.yaml", {
      monitoring_namespace = kubernetes_namespace.monitoring.metadata[0].annotations.name
      odahu_infra_version  = var.odahu_infra_version

      nginx_annotations = yamlencode({ annotations = local.ingress_nginx_annotations })

      cluster_domain          = var.cluster_domain
      prom_retention_time     = var.prom_retention_time
      prom_retention_size     = var.prom_retention_size
      prom_storage_size       = var.prom_storage_size
      grafana_admin           = var.grafana_admin
      grafana_pass            = var.grafana_pass
      grafana_storage_size    = var.grafana_storage_size
      grafana_image_tag       = var.grafana_image_tag
      ingress_tls_secret_name = local.ingress_tls_secret_name

      grafana_pgsql_enabled  = var.pgsql.enabled
      grafana_pgsql_url = format(
        "postgres://%s:%s@%s:%s/%s",
        local.grafana_pg_username,
        local.grafana_pg_password,
        var.pgsql.db_host,
        "5432",
        var.pgsql.db_name
      )
    })
  ]
  depends_on = [kubernetes_secret.tls_monitoring]
}

resource "kubernetes_config_map" "grafana_dashboard" {
  metadata {
    annotations = {
      k8s-sidecar-target-directory = "/tmp/dashboards/k8s"
    }
    labels = {
      grafana_dashboard = "1"
    }
    name      = "psql-dashboard.json"
    namespace = var.monitoring_namespace
  }

  data = {
    "psql-dashboard.json" = file("${path.module}/files/grafana-psql-dashboard.json")
  }
}

resource "local_file" "grafana_pg_dashboard" {
  count = var.pgsql.enabled ? 1 : 0
  content = templatefile("${path.module}/templates/grafana_pg_dashboard_manifest.tpl", {
    namespace    = var.db_namespace
  })
  filename = "/tmp/.odahu/grafana_pg_dashboard.yml"

  file_permission      = 0644
  directory_permission = 0755

  depends_on = [helm_release.monitoring]
}

resource "null_resource" "grafana_pg_dashboard" {
  count = var.pgsql.enabled ? 1 : 0
  provisioner "local-exec" {
    interpreter = ["timeout", "1m", "bash", "-c"]

    command = "until kubectl apply -f ${local_file.grafana_pg_dashboard[0].filename}; do sleep 5; done"
  }
  depends_on = [local_file.grafana_pg_dashboard[0]]
}
