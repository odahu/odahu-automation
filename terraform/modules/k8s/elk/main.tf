locals {
  es_cluster_name = "es"
  es_node_group   = "odahu"

  ingress_tls_enabled     = var.tls_secret_crt != "" && var.tls_secret_key != ""
  url_schema              = local.ingress_tls_enabled ? "https" : "http"
  ingress_tls_secret_name = "odahu-flow-tls"

  ingress_common = {
    enabled     = true
    hosts       = [var.cluster_domain]
    path        = "/kibana"
    annotations = {
      "kubernetes.io/ingress.class"                       = "nginx"
      "nginx.ingress.kubernetes.io/force-ssl-redirect"    = "true"
      "nginx.ingress.kubernetes.io/auth-signin"           = format("https://%s/oauth2/start?rd=https://$host$escaped_request_uri", var.cluster_domain)
      "nginx.ingress.kubernetes.io/auth-url"              = "http://oauth2-proxy.kube-system.svc.cluster.local:4180/oauth2/auth"
      "nginx.ingress.kubernetes.io/configuration-snippet" = <<-EOT
        rewrite          ^/kibana(/|$)(.*) /$2 break;
        set_escape_uri   $escaped_request_uri $request_uri;
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
}

module "docker_credentials" {
  source          = "../docker_auth"
  docker_repo     = var.docker_repo
  docker_username = var.docker_username
  docker_password = var.docker_password
  namespaces      = [kubernetes_namespace.elasticsearch[0].metadata[0].annotations.name]
}

resource "null_resource" "add_elastic_helm_repo" {
  count = var.elasticsearch_enabled ? 1 : 0
  triggers = {
    build_number = timestamp()
  }
  provisioner "local-exec" {
    command = "helm repo add elastic ${var.elasticsearch_helm_repo}"
  }
}

resource "kubernetes_namespace" "elasticsearch" {
  count = var.elasticsearch_enabled ? 1 : 0
  metadata {
    annotations = {
      name = var.elasticsearch_namespace
    }
    labels = {
      project = "odahu-flow"
    }
    name = var.elasticsearch_namespace
  }
  depends_on = [null_resource.add_elastic_helm_repo[0]]
}

resource "kubernetes_secret" "ingress_tls" {
  count = var.elasticsearch_enabled && local.ingress_tls_enabled ? 1 : 0
  metadata {
    name      = local.ingress_tls_secret_name
    namespace = kubernetes_namespace.elasticsearch[0].metadata[0].annotations.name
  }
  data = {
    "tls.key" = var.tls_secret_key
    "tls.crt" = var.tls_secret_crt
  }
  type = "kubernetes.io/tls"

  depends_on = [kubernetes_namespace.elasticsearch[0]]
}

resource "kubernetes_secret" "sa" {
  metadata {
    name      = "logstash-gke-sa"
    namespace = var.elasticsearch_namespace
  }
  data = {
    "logstash-gke-sa" = var.sa_key
  }
  type       = "opaque"
  depends_on = [kubernetes_namespace.elasticsearch[0]]
}

resource "helm_release" "elasticsearch" {
  count      = var.elasticsearch_enabled ? 1 : 0
  name       = "elasticsearch"
  repository = "elastic"
  chart      = "elasticsearch"
  version    = var.elasticsearch_chart_version
  namespace  = kubernetes_namespace.elasticsearch[0].metadata[0].annotations.name

  values = [
    templatefile("${path.module}/templates/elasticsearch.yaml", {
      cluster_name = local.es_cluster_name
      node_group   = local.es_node_group
      es_replicas  = var.elasticsearch_replicas
      es_java_opts = "-Xmx1g -Xms1g"
      storage_size = var.storage_size
    }),
  ]

  depends_on = [
    null_resource.add_elastic_helm_repo[0],
    kubernetes_namespace.elasticsearch[0]
  ]
}

resource "helm_release" "kibana" {
  count      = var.elasticsearch_enabled ? 1 : 0
  name       = "kibana"
  repository = "elastic"
  chart      = "kibana"
  version    = var.kibana_chart_version
  namespace  = kubernetes_namespace.elasticsearch[0].metadata[0].annotations.name

  values = [
    templatefile("${path.module}/templates/kibana.yaml", {
      es_service_url = format("http://%s-%s.%s.svc.cluster.local:9200",
        local.es_cluster_name,
        local.es_node_group,
        kubernetes_namespace.elasticsearch[0].metadata[0].annotations.name
      )

      kibana_image     = "docker.elastic.co/kibana/kibana"
      kibana_image_tag = var.kibana_chart_version
      ingress_config   = yamlencode({ ingress = local.ingress_config })
    })
  ]

  depends_on = [
    null_resource.add_elastic_helm_repo[0],
    kubernetes_namespace.elasticsearch[0],
    helm_release.elasticsearch[0]
  ]
}

resource "helm_release" "logstash" {
  count      = var.elasticsearch_enabled ? 1 : 0
  name       = "logstash"
  repository = "elastic"
  chart      = "logstash"
  version    = var.logstash_chart_version
  namespace  = kubernetes_namespace.elasticsearch[0].metadata[0].annotations.name

  values = [
    templatefile("${path.module}/templates/logstash.yaml", {
      logstash_replicas = var.logstash_replicas
      version           = var.odahu_infra_version
      bucket            = var.bucket
      es_service_url = format("%s-%s.%s.svc.cluster.local:9200",
        local.es_cluster_name,
        local.es_node_group,
        kubernetes_namespace.elasticsearch[0].metadata[0].annotations.name
      )
    })
  ]

  depends_on = [
    null_resource.add_elastic_helm_repo[0],
    kubernetes_namespace.elasticsearch[0],
    helm_release.elasticsearch[0]
  ]
}
