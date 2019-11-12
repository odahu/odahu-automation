locals {
  gcp_resource_count = var.cluster_type == "gcp/gke" ? 1 : 0
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
  count      = local.gcp_resource_count
  name       = "gke-saa"
  chart      = "k8s-gke-saa"
  version    = var.odahu_infra_version
  repository = "odahuflow"
  namespace  = "kube-system"

  values = [
    data.template_file.gke_saa_values.rendered
  ]
}
