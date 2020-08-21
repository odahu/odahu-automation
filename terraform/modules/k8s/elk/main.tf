locals {
  es_cluster_name = "es"
  es_node_group   = "odahu"
  es_service_url = format(
    "%s-%s.%s.svc.cluster.local:9200",
    local.es_cluster_name,
    local.es_node_group,
    kubernetes_namespace.elk[0].metadata[0].annotations.name
  )

  secret_mounts = length(var.sa_key) == 0 ? { secretMounts = [] } : {
    secretMounts = [{
      name       = "logstash-gke-sa",
      secretName = "logstash-gke-sa",
      path       = "/credentials"
    }]
  }

  logstash_config = {
    "logstashPipeline" = {
      "logstash.conf" = format(
        "%s%s%s",
        var.logstash_input_config,
        templatefile("${path.module}/templates/logstash_filter.tpl", {}),
        templatefile("${path.module}/templates/logstash_output.tpl", {
          es_service_url = local.es_service_url
        })
      )
    }
  }

  ingress_tls_enabled     = var.tls_secret_crt != "" && var.tls_secret_key != ""
  url_schema              = local.ingress_tls_enabled ? "https" : "http"
  ingress_tls_secret_name = "odahu-flow-tls"

  ingress_common = {
    enabled = true
    hosts   = [var.cluster_domain]
    path    = "/kibana"
    annotations = {
      "kubernetes.io/ingress.class"                    = "nginx"
      "nginx.ingress.kubernetes.io/force-ssl-redirect" = "true"
      "nginx.ingress.kubernetes.io/auth-signin" = format(
        "https://%s/oauth2/start?rd=https://$host$escaped_request_uri",
        var.cluster_domain
      )
      "nginx.ingress.kubernetes.io/auth-url"              = "http://oauth2-proxy.kube-system.svc.cluster.local:4180/oauth2/auth"
      "nginx.ingress.kubernetes.io/configuration-snippet" = <<-EOT
        rewrite          ^/kibana(/|$)(.*) /$2 break;
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
      "nginx.ingress.kubernetes.io/auth-snippet"          = <<-EOT
        proxy_set_header X-User        $user;
        proxy_set_header X-Email       $email;
        proxy_set_header X-JWT         $jwt;
        proxy_set_header Authorization "Bearer $jwt";
      EOT
    }
  }

  ingress_tls = local.ingress_tls_enabled ? {
    tls = [
      { secretName = local.ingress_tls_secret_name, hosts = [var.cluster_domain] }
    ]
  } : {}

  ingress_config = merge(local.ingress_common, local.ingress_tls)

  policies = [
    {
      name = "logstash-policy",
      json = jsonencode({
        "policy" = {
          "phases" = {
            "hot"    = { "min_age" = "0ms", "actions" = { "rollover" = { "max_size" = "1GB" } } },
            "delete" = { "min_age" = "4d", "actions" = { "delete" = {} } }
          }
        }
      })
    },
    {
      name = "odahu-flow-policy",
      json = jsonencode({
        "policy" = {
          "phases" = {
            "hot"    = { "min_age" = "0ms", "actions" = { "rollover" = { "max_size" = "1GB" } } },
            "delete" = { "min_age" = "25d", "actions" = { "delete" = {} } }
          }
        }
      })
    }
  ]

  templates = [
    {
      "name" = "logstash",
      "json" = jsonencode({
        "index_patterns" = ["logstash-*"],
        "settings" = {
          "number_of_shards"               = 1,
          "number_of_replicas"             = "${var.elasticsearch_replicas - 1}",
          "index.lifecycle.name"           = "logstash-policy",
          "index.lifecycle.rollover_alias" = "logstash"
        },
        "mappings" = {
          "_doc" = { "properties" = { "@timestamp" = { "type" = "date" } } }
        }
      }),
      "alias" = jsonencode({
        "aliases" = { "logstash" = { "is_write_index" = true } }
      })
    },
    {
      "name" = "odahu-flow",
      "json" = jsonencode({
        "index_patterns" = ["odahu-flow-*"],
        "settings" = {
          "number_of_shards"               = 1,
          "number_of_replicas"             = "${var.elasticsearch_replicas - 1}",
          "index.lifecycle.name"           = "odahu-flow-policy",
          "index.lifecycle.rollover_alias" = "odahu-flow"
        },
        "mappings" = {
          "_doc" = { "properties" = { "@timestamp" = { "type" = "date" } } }
        }
      }),
      "alias" = jsonencode({
        "aliases" = { "odahu-flow" = { "is_write_index" = true } }
      })
    }
  ]
}

module "docker_credentials" {
  source          = "../docker_auth"
  docker_repo     = var.docker_repo
  docker_username = var.docker_username
  docker_password = var.docker_password
  namespaces      = var.elk_enabled ? [kubernetes_namespace.elk[0].metadata[0].annotations.name] : []
}

resource "kubernetes_namespace" "elk" {
  count = var.elk_enabled ? 1 : 0
  metadata {
    annotations = {
      name = var.elk_namespace
    }
    labels = {
      project = "odahu-flow"
    }
    name = var.elk_namespace
  }
}

resource "kubernetes_secret" "ingress_tls" {
  count = var.elk_enabled && local.ingress_tls_enabled ? 1 : 0
  metadata {
    name      = local.ingress_tls_secret_name
    namespace = kubernetes_namespace.elk[0].metadata[0].annotations.name
  }
  data = {
    "tls.key" = var.tls_secret_key
    "tls.crt" = var.tls_secret_crt
  }
  type = "kubernetes.io/tls"

  depends_on = [kubernetes_namespace.elk[0]]
}

resource "kubernetes_secret" "sa" {
  count = var.cloud_type == "gcp" ? 1 : 0

  metadata {
    name      = "logstash-gke-sa"
    namespace = kubernetes_namespace.elk[0].metadata[0].annotations.name
  }
  data = {
    "logstash-gke-sa" = var.sa_key
  }
  type = "Opaque"
}

resource "helm_release" "elasticsearch" {
  count      = var.elk_enabled ? 1 : 0
  name       = "elasticsearch"
  repository = var.elasticsearch_helm_repo
  chart      = "elasticsearch"
  version    = var.elasticsearch_chart_version
  namespace  = kubernetes_namespace.elk[0].metadata[0].annotations.name
  timeout    = var.helm_timeout

  values = [
    templatefile("${path.module}/templates/elasticsearch.yaml", {
      cluster_name = local.es_cluster_name
      node_group   = local.es_node_group
      es_replicas  = var.elasticsearch_replicas
      es_mem       = var.elasticsearch_memory
      storage_size = var.storage_size

      policies  = local.policies
      templates = local.templates
    })
  ]

  depends_on = [kubernetes_namespace.elk[0]]
}

resource "helm_release" "kibana" {
  count      = var.elk_enabled ? 1 : 0
  name       = "kibana"
  repository = var.elasticsearch_helm_repo
  chart      = "kibana"
  version    = var.kibana_chart_version
  namespace  = kubernetes_namespace.elk[0].metadata[0].annotations.name
  timeout    = var.helm_timeout

  values = [
    templatefile("${path.module}/templates/kibana.yaml", {
      es_service_url   = "http://${local.es_service_url}"
      kibana_image     = "docker.elastic.co/kibana/kibana"
      kibana_image_tag = var.kibana_chart_version
      ingress_config   = yamlencode({ ingress = local.ingress_config })
    })
  ]

  depends_on = [
    kubernetes_namespace.elk[0],
    helm_release.elasticsearch[0]
  ]
}

resource "kubernetes_config_map" "kibana_loader_data" {
  count = var.elk_enabled ? 1 : 0
  metadata {
    name      = "kibana-loader-data"
    namespace = var.elk_namespace
  }
  data = {
    "kibana_odahu_stuff"   = file("${path.module}/files/kibana_odahu_stuff.ndjson")
    "kibana_loader_script" = file("${path.module}/files/kibana_loader.sh")
  }
  depends_on = [
    kubernetes_namespace.elk[0]
  ]
}

resource "kubernetes_job" "kibana_loader" {
  count = var.elk_enabled ? 1 : 0
  metadata {
    name      = "kibana-loader"
    namespace = var.elk_namespace
  }
  spec {
    template {
      metadata {}
      spec {
        volume {
          name = "import-script"
          config_map {
            name = kubernetes_config_map.kibana_loader_data[0].metadata[0].name
            items {
              key  = "kibana_loader_script"
              path = "import.sh"
              mode = "0755"
            }
          }
        }
        volume {
          name = "kibana-data"
          config_map {
            name = kubernetes_config_map.kibana_loader_data[0].metadata[0].name
            items {
              key  = "kibana_odahu_stuff"
              path = "kibana_odahu_stuff.ndjson"
            }
          }
        }
        container {
          name    = "kibana-loader"
          image   = "docker.elastic.co/kibana/kibana:${var.kibana_chart_version}"
          command = ["/opt/bin/import.sh"]
          env {
            name = "KIBANA_URL"
            value = format("http://kibana.%s.svc:5601",
              kubernetes_namespace.elk[0].metadata[0].annotations.name
            )
          }
          volume_mount {
            name       = "kibana-data"
            mount_path = "/opt/kibana-import-data/"
          }
          volume_mount {
            name       = "import-script"
            mount_path = "/opt/bin/"
          }
        }
        restart_policy = "Never"
      }
    }
    backoff_limit = 0
  }
  wait_for_completion = true

  depends_on = [
    helm_release.kibana[0],
    kubernetes_config_map.kibana_loader_data[0]
  ]
}

resource "helm_release" "logstash" {
  count      = var.elk_enabled ? 1 : 0
  name       = "logstash"
  repository = var.elasticsearch_helm_repo
  chart      = "logstash"
  version    = var.logstash_chart_version
  namespace  = kubernetes_namespace.elk[0].metadata[0].annotations.name
  timeout    = var.helm_timeout

  values = [
    templatefile("${path.module}/templates/logstash.yaml", {
      secret_mounts      = yamlencode(local.secret_mounts)
      config             = yamlencode(local.logstash_config)
      replicas           = var.logstash_replicas
      annotations        = length(var.logstash_annotations) == 0 ? "" : yamlencode(var.logstash_annotations)
      logstash_image     = "${var.docker_repo}/odahu-flow-logstash-oss"
      logstash_image_tag = var.odahu_infra_version
    })
  ]

  depends_on = [
    kubernetes_namespace.elk[0],
    helm_release.elasticsearch[0]
  ]
}
