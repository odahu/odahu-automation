provider "kubernetes" {
  config_context_auth_info  = "${var.config_context_auth_info}"
  config_context_cluster    = "${var.config_context_cluster}"
}

##############
# HELM Init
##############

resource "kubernetes_service_account" "tiller" {
  metadata {
    name        = "tiller"
    namespace   = "kube-system"
  }
}
resource "kubernetes_cluster_role_binding" "tiller" {
  metadata {
        name    = "tiller"
  }
  subject {
    api_group   = "rbac.authorization.k8s.io"
    kind        = "User"
    name        = "system:serviceaccount:kube-system:tiller"
  }

  role_ref {
    api_group   = "rbac.authorization.k8s.io"
    kind        = "ClusterRole"
    name        = "cluster-admin"
  }
  depends_on    = ["kubernetes_service_account.tiller"]
}