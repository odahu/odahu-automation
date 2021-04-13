locals {
  tenants = {
    tenants = [{
      name      = "argo",
      namespace = var.configuration.namespace,
      scheduler = {},
      pools = [{
        servers          = 1,
        volumesPerServer = 1,
        size             = "10Gi"
      }],
      secrets = {
        name      = "argo",
        accessKey = "argo",
        secretKey = "argo"
      },
      metrics = {
        enabled = true
      },
      s3 = {
        bucketDNS = true
      },
      console = {
        secrets = {
          name       = "console-secret",
          passphrase = "ThisIsAVeryLongPasswordForExample",
          salt       = "ThisIsAVeryLongPasswordForExample",
          accessKey  = "ThisIsAVeryLongPasswordForExample",
          secretKey  = "ThisIsAVeryLongPasswordForExample"
        }
      }
    }]
  }

  ingress_auth_signin = format(
    "https://%s/oauth2/start?rd=https://$host$escaped_request_uri",
    var.cluster_domain
  )
  ingress_auth_url = "http://oauth2-proxy.kube-system.svc.cluster.local:4180/oauth2/auth"

  ingress_tls_enabled     = var.tls_secret_crt != "" && var.tls_secret_key != ""
  url_schema              = local.ingress_tls_enabled ? "https" : "http"
  ingress_tls_secret_name = "odahu-flow-tls"

  ingress_tls = local.ingress_tls_enabled ? {
    tls = [{ secretName = local.ingress_tls_secret_name }]
  } : {}
}

resource "kubernetes_namespace" "minio_operator" {
  metadata {
    annotations = {
      name = var.configuration.namespace
    }
    name = var.configuration.namespace
  }
}

resource "kubernetes_secret" "tls_odahuflow" {
  count = local.ingress_tls_enabled ? 1 : 0

  metadata {
    name      = local.ingress_tls_secret_name
    namespace = var.configuration.namespace
  }
  data = {
    "tls.key" = var.tls_secret_key
    "tls.crt" = var.tls_secret_crt
  }
  type = "kubernetes.io/tls"

  depends_on = [kubernetes_namespace.minio_operator]
}

resource "helm_release" "minio_operator" {
  name          = "minio-operator"
  repository    = var.helm_repo
  chart         = "minio-operator"
  version       = var.helm_chart_version
  namespace     = var.configuration.namespace
  recreate_pods = true
  timeout       = var.helm_timeout
  values = [
    templatefile("${path.module}/templates/minio-operator.yaml", {
      tenants = yamlencode(local.tenants)
    })
  ]
  depends_on = [kubernetes_namespace.minio_operator]
}

resource "kubernetes_ingress" "minio_console" {
  metadata {
    name      = "minio-console"
    namespace = var.configuration.namespace
    annotations = {
      "kubernetes.io/ingress.class"                       = "nginx"
      "nginx.ingress.kubernetes.io/force-ssl-redirect"    = "true"
      "nginx.ingress.kubernetes.io/auth-signin"           = local.ingress_auth_signin
      "nginx.ingress.kubernetes.io/auth-url"              = local.ingress_auth_url
      "nginx.ingress.kubernetes.io/rewrite-target"        = "/$1"
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

  spec {
    backend {
      service_name = "console"
      service_port = 9090
    }

    rule {
      host = var.cluster_domain
      http {
        path {
          backend {
            service_name = "console"
            service_port = 9090
          }

          path = "/minio/?(.*)"
        }
        path {
          backend {
            service_name = "console"
            service_port = 9090
          }
          path = "/minio"
        }
      }
    }

    tls {
      secret_name = "tls-secret"
    }
  }

  depends_on = [helm_release.minio_operator, kubernetes_secret.tls_odahuflow]
}
