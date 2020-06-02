locals {
  ingress_tls_secret_name = "odahu-flow-tls"

  ingress_nginx_annotations = {
    "kubernetes.io/ingress.class"                       = "nginx"
    "nginx.ingress.kubernetes.io/force-ssl-redirect"    = "true"
    "nginx.ingress.kubernetes.io/configuration-snippet" = <<-EOT
      rewrite          ^\/[\w-]+(\/|$)(.*) /$2 break;
      set_escape_uri   $escaped_request_uri $request_uri;
      auth_request_set $user   $upstream_http_x_auth_request_user;
      auth_request_set $email  $upstream_http_x_auth_request_email;
      auth_request_set $jwt    $upstream_http_x_auth_request_access_token;
      auth_request_set $_oauth2_proxy_1 $upstream_cookie__oauth2_proxy_1;

      access_by_lua_block {
        if ngx.var._oauth2_proxy_1 ~= "" then
          ngx.header["Set-Cookie"] = "_oauth2_proxy_1=" .. ngx.var._oauth2_proxy_1 .. ngx.var.auth_cookie:match("(; .*)")
        end
      }
    EOT
    "nginx.ingress.kubernetes.io/auth-signin"           = format("https://%s/oauth2/start?rd=https://$host$escaped_request_uri", var.cluster_domain)
    "nginx.ingress.kubernetes.io/auth-url"              = "http://oauth2-proxy.kube-system.svc.cluster.local:4180/oauth2/auth"
  }

  ingress_nginx_grafana_auth_snippet = {
    "nginx.ingress.kubernetes.io/auth-snippet" = <<-EOT
      proxy_set_header X-User  $user;
      proxy_set_header X-Email $email;
      proxy_set_header X-JWT   $jwt;
      proxy_set_header Authorization "";
    EOT
  }

  ingress_nginx_prometheus_auth_snippet = {
    "nginx.ingress.kubernetes.io/auth-snippet" = <<-EOT
      proxy_set_header X-User  $user;
      proxy_set_header X-Email $email;
      proxy_set_header X-JWT   $jwt;
      proxy_set_header Authorization "Bearer $jwt";
    EOT
  }

  grafana_annotations    = merge(local.ingress_nginx_annotations, local.ingress_nginx_grafana_auth_snippet)
  prometheus_annotations = merge(local.ingress_nginx_annotations, local.ingress_nginx_prometheus_auth_snippet)
}

########################################################
# Prometheus monitoring
########################################################
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
  repository = "odahuflow"
  timeout    = var.helm_timeout

  values = [
    templatefile("${path.module}/templates/monitoring.yaml", {
      monitoring_namespace = kubernetes_namespace.monitoring.metadata[0].annotations.name
      odahu_infra_version  = var.odahu_infra_version

      grafana_annotations = yamlencode({ annotations = local.grafana_annotations })
      prom_annotations    = yamlencode({ annotations = local.prometheus_annotations })

      cluster_domain          = var.cluster_domain
      prom_retention_time     = var.prom_retention_time
      prom_retention_size     = var.prom_retention_size
      prom_storage_size       = var.prom_storage_size
      grafana_admin           = var.grafana_admin
      grafana_pass            = var.grafana_pass
      grafana_storage_size    = var.grafana_storage_size
      storage_class           = var.storage_class
      ingress_tls_secret_name = local.ingress_tls_secret_name
    })
  ]
}
