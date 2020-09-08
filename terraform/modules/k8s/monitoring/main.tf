locals {
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

  grafana_dashboards = fileset("${path.module}/files/dashboards", "**")
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
      project       = "odahu-flow"
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

resource "helm_release" "prometheus" {
  name       = "monitoring"
  chart      = "prometheus-operator"
  version    = "9.3.1"
  namespace  = kubernetes_namespace.monitoring.metadata[0].annotations.name
  repository = "https://kubernetes-charts.storage.googleapis.com"
  timeout    = var.helm_timeout

  values = [
    templatefile("${path.module}/templates/prometheus_operator.yaml", {
      nginx_annotations = yamlencode({ annotations = local.ingress_nginx_annotations })

      name                    = "monitoring"
      cluster_domain          = var.cluster_domain
      prom_retention_time     = var.prom_retention_time
      prom_retention_size     = var.prom_retention_size
      prom_storage_size       = var.prom_storage_size
      ingress_tls_secret_name = local.ingress_tls_secret_name
    })
  ]
  depends_on = [kubernetes_secret.tls_monitoring]
}

resource "local_file" "prometheus_stuff" {
  content = templatefile("${path.module}/templates/prometheus_cr.yaml", {
    prometheus_name = helm_release.prometheus.name
    namespace       = var.monitoring_namespace
  })
  filename = "/tmp/.odahu/prometheus_stuff.yml"

  file_permission      = 0644
  directory_permission = 0755

  depends_on = [helm_release.prometheus]
}

resource "null_resource" "prometheus_stuff" {
  provisioner "local-exec" {
    interpreter = ["timeout", "1m", "bash", "-c"]

    command = "until kubectl apply -f ${local_file.prometheus_stuff.filename}; do sleep 5; done"
  }
  depends_on = [local_file.prometheus_stuff]
}

resource "helm_release" "grafana" {
  name       = "grafana"
  chart      = "grafana"
  version    = "5.5.5"
  namespace  = kubernetes_namespace.monitoring.metadata[0].annotations.name
  repository = "https://kubernetes-charts.storage.googleapis.com"
  timeout    = var.helm_timeout

  values = [
    templatefile("${path.module}/templates/grafana.yaml", {
      nginx_annotations = yamlencode({ annotations = local.ingress_nginx_annotations })

      cluster_domain          = var.cluster_domain
      grafana_admin           = var.grafana_admin
      grafana_pass            = var.grafana_pass
      grafana_storage_size    = var.grafana_storage_size
      grafana_image_tag       = var.grafana_image_tag
      ingress_tls_secret_name = local.ingress_tls_secret_name
    })
  ]
  depends_on = [null_resource.prometheus_stuff]
}

resource "kubernetes_config_map" "dashboard" {
  for_each = toset(local.grafana_dashboards)

  metadata {
    name      = basename(each.value)
    namespace = kubernetes_namespace.monitoring.metadata[0].annotations.name
    annotations = {
      "k8s-sidecar-target-directory" = "/tmp/dashboards/${dirname(each.value)}"
    }
    labels = {
      "grafana_dashboard" = "1"
    }
  }

  data = {
    basename(each.value) = file("${path.module}/files/dashboards/${each.value}")
  }

  depends_on = [helm_release.grafana]
}
