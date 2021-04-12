locals {
  mode_label_value = lookup(lookup(var.configuration.node_pool[keys(var.configuration.node_pool)[0]], "labels", []), "mode", "")

  use_static_credentials = var.sa_annotations == {} ? false : true
  pg_credentials_plain = ((length(var.pgsql.secret_namespace) != 0) && (length(var.pgsql.secret_name) != 0)) ? 0 : 1

  pg_username = local.pg_credentials_plain == 1 ? var.pgsql.db_password : lookup(lookup(data.kubernetes_secret.pg[0], "data", {}), "username", "")
  pg_password = local.pg_credentials_plain == 1 ? var.pgsql.db_user : lookup(lookup(data.kubernetes_secret.pg[0], "data", {}), "password", "")

  workflows_namespace = var.configuration.workflows_namespace == "" ? var.configuration.namespace : var.configuration.workflows_namespace

  server = {
    server = {
      baseHref                  = "/argo/"
      serviceAccountAnnotations = var.sa_annotations
    }
  }

  workflow = {
    workflow = {
      namespace = local.workflows_namespace
      serviceAccount = {
        create      = true
        annotations = var.sa_annotations
      }
      rbac = {
        create = true
      }
    }
  }

  artifact_repository = {
    artifactRepository = merge({ archiveLogs = true }, var.artifact_repository_config)
  }

  controller = {
    controller = {
      serviceAccountAnnotations = var.sa_annotations
      workflowDefaults = {
        metadata = {
          namespace = local.workflows_namespace
        }
        spec = {
          serviceAccountName = "argo-workflow"

          tolerations = length(var.configuration.node_pool) != 0 ? [
            for taint in lookup(var.configuration.node_pool[keys(var.configuration.node_pool)[0]], "taints", []) : {
              Key      = taint.key
              Operator = "Equal"
              Value    = taint.value
              Effect   = replace(taint.effect, "/(?i)no_?schedule/", "NoSchedule")
          }] : null

          affinity = length(local.mode_label_value) != 0 ? {
            nodeAffinity = {
              requiredDuringSchedulingIgnoredDuringExecution = {
                nodeSelectorTerms = [{
                  matchExpressions = [{
                    key      = "mode"
                    operator = "In"
                    values   = [local.mode_label_value]
                  }]
                }]
              }
            }
          } : null
        }
      }
      workflowNamespaces = var.configuration.workflows_namespace == "" ? [var.configuration.namespace] : [var.configuration.workflows_namespace]

      persistence = {
        postgresql = {
          host      = var.pgsql.db_host
          port      = 5432
          database  = var.pgsql.db_name
          tableName = "argo_workflows"
          userNameSecret = {
            name = kubernetes_secret.postgres[0].metadata[0].name
            key  = "username"
          }
          passwordSecret = {
            name = kubernetes_secret.postgres[0].metadata[0].name
            key  = "password"
          }
          ssl     = true
          sslMode = "require"
        }
      }
    }
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

resource "kubernetes_namespace" "argo" {
  metadata {
    annotations = {
      name = var.configuration.namespace
    }
    name = var.configuration.namespace
  }
}

resource "kubernetes_namespace" "argo_workflows" {
  count = var.configuration.workflows_namespace == "" ? 0 : 1

  metadata {
    annotations = {
      name = var.configuration.workflows_namespace
    }
    name = var.configuration.workflows_namespace
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

  depends_on = [kubernetes_namespace.argo]
}

data "kubernetes_secret" "pg" {
  count = local.pg_credentials_plain == 0 ? 1 : 0

  metadata {
    name      = var.pgsql.secret_name
    namespace = var.pgsql.secret_namespace
  }
}

resource "kubernetes_secret" "postgres" {
  count = var.configuration.enabled && var.pgsql.enabled ? 1 : 0

  metadata {
    name      = "postgres"
    namespace = var.configuration.namespace
  }
  data = {
    "username" = local.pg_username
    "password" = local.pg_password
  }
  type = "Opaque"

  depends_on = [kubernetes_namespace.argo]
}

resource "helm_release" "argo_workflows" {
  count = var.configuration.enabled ? 1 : 0

  name          = "argo-workflows"
  repository    = var.helm_repo
  chart         = "argo"
  version       = var.argo_wf_helm_chart_version
  namespace     = var.configuration.namespace
  recreate_pods = true
  timeout       = var.helm_timeout
  values = [
    templatefile("${path.module}/templates/argo-workflows.yaml", {
      controller          = yamlencode(local.controller)
      pgsql_enabled       = var.pgsql.enabled
      workflow            = yamlencode(local.workflow)
      artifact_repository = yamlencode(local.artifact_repository)
      server              = yamlencode(local.server)
      use_static_credentials = local.use_static_credentials
      argo_version = var.argo_version
    })
  ]
  depends_on = [kubernetes_namespace.argo, kubernetes_secret.postgres[0]]
}

resource "kubernetes_ingress" "argo_workflows" {
  metadata {
    name      = "argo-workflows-server"
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
      service_name = "argo-workflows-server"
      service_port = 2746
    }

    rule {
      host = var.cluster_domain
      http {
        path {
          backend {
            service_name = "argo-workflows-server"
            service_port = 2746
          }

          path = "/argo/?(.*)"
        }
        path {
          backend {
            service_name = "argo-workflows-server"
            service_port = 2746
          }

          path = "/argo"
        }
      }
    }

    tls {
      secret_name = "tls-secret"
    }
  }

  depends_on = [helm_release.argo_workflows, kubernetes_secret.tls_odahuflow]
}
