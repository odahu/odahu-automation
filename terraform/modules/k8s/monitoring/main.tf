locals {
  grafana_pg_credentials_plain = ((length(var.pgsql_grafana.secret_namespace) != 0) && (length(var.pgsql_grafana.secret_name) != 0)) ? 0 : 1

  grafana_pg_username = local.grafana_pg_credentials_plain == 1 ? var.pgsql_grafana.db_password : lookup(lookup(data.kubernetes_secret.pg[0], "data", {}), "username", "")
  grafana_pg_password = local.grafana_pg_credentials_plain == 1 ? var.pgsql_grafana.db_user : lookup(lookup(data.kubernetes_secret.pg[0], "data", {}), "password", "")

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
    name      = var.pgsql_grafana.secret_name
    namespace = var.pgsql_grafana.secret_namespace
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
  chart      = "kube-prometheus-stack"
  version    = var.monitoring_chart_version
  namespace  = kubernetes_namespace.monitoring.metadata[0].annotations.name
  repository = var.helm_repo
  timeout    = var.helm_timeout

  values = [
    templatefile("${path.module}/templates/monitoring.yaml", {
      db_namespace         = var.db_namespace
      monitoring_namespace = var.monitoring_namespace

      nginx_annotations = yamlencode({ annotations = local.ingress_nginx_annotations })

      cluster_domain          = var.cluster_domain
      prom_retention_time     = var.prom_retention_time
      prom_retention_size     = var.prom_retention_size
      prom_storage_size       = var.prom_storage_size
      grafana_admin           = var.grafana_admin
      grafana_pass            = var.grafana_pass
      grafana_storage_size    = var.grafana_storage_size
      ingress_tls_secret_name = local.ingress_tls_secret_name

      grafana_pgsql_enabled = var.pgsql_grafana.enabled
      grafana_pgsql_url = format(
        "postgres://%s:%s@%s:%s/%s",
        local.grafana_pg_username,
        local.grafana_pg_password,
        var.pgsql_grafana.db_host,
        "5432",
        var.pgsql_grafana.db_name
      )
    })
  ]
  depends_on = [kubernetes_secret.tls_monitoring]
}

resource "kubernetes_config_map" "pg_grafana_dashboard" {
  for_each = fileset("${path.module}/dashboards/postgresql", "*")
  metadata {
    annotations = {
      k8s-sidecar-target-directory = "/tmp/dashboards/postgresql"
    }
    labels = {
      grafana_dashboard = "1"
    }
    name      = each.value
    namespace = var.monitoring_namespace
  }

  data = {
    "${each.value}" = file("${path.module}/dashboards/postgresql/${each.value}")
  }
  depends_on = [kubernetes_namespace.monitoring]
}

resource "kubernetes_config_map" "istio_grafana_dashboard" {
  for_each = fileset("${path.module}/dashboards/istio", "*")
  metadata {
    annotations = {
      k8s-sidecar-target-directory = "/tmp/dashboards/istio"
    }
    labels = {
      grafana_dashboard = "1"
    }
    name      = each.value
    namespace = var.monitoring_namespace
  }

  data = {
    "${each.value}" = file("${path.module}/dashboards/istio/${each.value}")
  }
  depends_on = [kubernetes_namespace.monitoring]
}

resource "kubernetes_config_map" "knative_grafana_dashboard" {
  for_each = fileset("${path.module}/dashboards/knative", "*")
  metadata {
    annotations = {
      k8s-sidecar-target-directory = "/tmp/dashboards/knative"
    }
    labels = {
      grafana_dashboard = "1"
    }
    name      = each.value
    namespace = var.monitoring_namespace
  }

  data = {
    "${each.value}" = file("${path.module}/dashboards/knative/${each.value}")
  }
  depends_on = [kubernetes_namespace.monitoring]
}

resource "kubernetes_config_map" "monitoring_grafana_dashboard" {
  for_each = fileset("${path.module}/dashboards/monitoring", "*")
  metadata {
    annotations = {
      k8s-sidecar-target-directory = "/tmp/dashboards/monitoring"
    }
    labels = {
      grafana_dashboard = "1"
    }
    name      = each.value
    namespace = var.monitoring_namespace
  }

  data = {
    "${each.value}" = file("${path.module}/dashboards/monitoring/${each.value}")
  }
  depends_on = [kubernetes_namespace.monitoring]
}
