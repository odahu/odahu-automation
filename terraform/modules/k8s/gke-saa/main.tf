provider "helm" {
  version         = "v0.10.0"
  install_tiller  = false
}

data "helm_repository" "legion" {
  name = "legion_github"
  url  = var.legion_helm_repo
}

########################################################
# k8s GKE Service Account Assigner
########################################################
data "template_file" "gke_saa_values" {
  template = file("${path.module}/templates/gke_saa.yaml")
  vars = {
    default_scopes = var.gke_saa_default_scopes
    default_sa     = var.gke_saa_default_sa
    sa_name        = var.gke_saa_sa_name
    image_repo     = var.gke_saa_image_repo
    image_tag      = var.gke_saa_image_tag
    host_port      = var.gke_saa_host_port
    container_port = var.gke_saa_container_port
    name           = var.gke_saa_name
  }
}

resource "helm_release" "gke_saa" {
  name       = "gke-saa"
  chart      = "k8s-gke-saa"
  version    = var.legion_infra_version
  repository = data.helm_repository.legion.metadata[0].name
  namespace  = "kube-system"

  values = [
    data.template_file.gke_saa_values.rendered
  ]
  depends_on  = [data.helm_repository.legion]
}

