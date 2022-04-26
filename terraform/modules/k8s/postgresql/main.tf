locals {
  helm_version = "1.6.0"

  kube_pg_status_cmd = "kubectl -n ${var.namespace} get postgresql ${var.configuration.cluster_name} -ojsonpath='{.status.PostgresClusterStatus}'"
}

resource "random_password" "exporter_user" {
  length           = 16
  special          = true
  override_special = "_%@#"
}

resource "kubernetes_namespace" "pgsql" {
  count = var.configuration.enabled ? 1 : 0
  metadata {
    annotations = {
      name = var.namespace
    }
    name = var.namespace
  }
}

resource "helm_release" "pg_operator" {
  count      = var.configuration.enabled ? 1 : 0
  name       = "odahu"
  chart      = "postgres-operator"
  version    = local.helm_version
  repository = var.helm_repo
  namespace  = var.namespace
  timeout    = var.helm_timeout

  set {
    name  = "configKubernetes.infrastructure_roles_secret_name"
    value = "postgresql-infrastructure-roles"
  }

  set {
    name  = "configGeneral.resync_period"
    value = var.configuration.resync_period
  }

  depends_on = [kubernetes_namespace.pgsql[0]]
}

resource "local_file" "pg_cluster" {
  count = var.configuration.enabled ? 1 : 0
  content = templatefile("${path.module}/templates/pg_crd_manifest.tpl", {
    namespace     = var.namespace
    storage_size  = var.configuration.storage_size
    storage_class = var.configuration.storage_class
    replicas      = var.configuration.replica_count
    cluster_name  = var.configuration.cluster_name
    databases     = var.databases
  })
  filename = "/tmp/.odahu/pg_cluster.yml"

  file_permission      = 0644
  directory_permission = 0755

  depends_on = [helm_release.pg_operator[0]]
}

resource "null_resource" "pg_cluster" {
  count = var.configuration.enabled ? 1 : 0
  provisioner "local-exec" {
    interpreter = ["timeout", "1m", "bash", "-c"]

    command = "until kubectl apply -f ${local_file.pg_cluster[0].filename}; do sleep 5; done"
  }
  depends_on = [local_file.pg_cluster[0]]
}

resource "null_resource" "pg_cluster_check" {
  count = var.configuration.enabled ? 1 : 0

  provisioner "local-exec" {
    interpreter = ["timeout", "5m", "bash", "-c"]

    command = "until [[ $(${local.kube_pg_status_cmd}) = 'Running' ]]; do sleep 5; done"
  }
  depends_on = [null_resource.pg_cluster[0]]
}

resource "kubernetes_secret" "infra_roles" {
  metadata {
    name      = "postgresql-infrastructure-roles"
    namespace = var.namespace
  }
  data = {
    "user1"     = "exporter"
    "password1" = random_password.exporter_user.result
    "inrole1"   = "pg_monitor"
  }
  type       = "Opaque"
  depends_on = [kubernetes_namespace.pgsql]
}
