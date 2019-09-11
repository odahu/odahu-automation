provider "kubernetes" {
  config_context_auth_info = var.config_context_auth_info
  config_context_cluster   = var.config_context_cluster
}

provider "helm" {
  version         = "v0.10.0"
  install_tiller  = true
  namespace       = "kube-system"
  service_account = "tiller"
  tiller_image    = ""
}

##############
# HELM Init
##############

locals {
  tiller_namespace = "kube-system"
}

resource "kubernetes_service_account" "tiller" {
  metadata {
    name      = "tiller"
    namespace = local.tiller_namespace
  }
}

resource "kubernetes_cluster_role_binding" "tiller" {
  metadata {
    name = "tiller"
  }
  subject {
    api_group = "rbac.authorization.k8s.io"
    kind      = "User"
    name      = "system:serviceaccount:${local.tiller_namespace}:tiller"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }
  depends_on = [kubernetes_service_account.tiller]
}

resource "null_resource" "install_tiller" {
  provisioner "local-exec" {
    command = "helm init --tiller-image ${var.tiller_image} --service-account tiller"
  }
  depends_on = [kubernetes_cluster_role_binding.tiller]
}

resource "null_resource" "wait_for_tiller" {
  triggers = {
    build_number = timestamp()
  }
  provisioner "local-exec" {
    command = "timeout 60 bash -c 'until kubectl get pods -n ${local.tiller_namespace} |grep tiller; do sleep 5; done'"
  }
  depends_on = [null_resource.install_tiller]
}

#########################
# add HELM repositories
#########################

resource "null_resource" "reinit_helm_client" {
  triggers = {
    build_number = timestamp()
  }
  provisioner "local-exec" {
    command = "helm init --client-only"
  }
  depends_on = [null_resource.wait_for_tiller]
}

resource "null_resource" "add_helm_repository_legion" {
  triggers = {
    build_number = timestamp()
  }
  provisioner "local-exec" {
    command = "helm repo add legion ${var.legion_helm_repo}"
  }
  depends_on = [null_resource.reinit_helm_client]
}

resource "null_resource" "add_helm_repository_istio" {
  triggers = {
    build_number = timestamp()
  }
  provisioner "local-exec" {
    command = "helm repo add istio ${var.istio_helm_repo}"
  }
  depends_on = [null_resource.add_helm_repository_legion]
}
