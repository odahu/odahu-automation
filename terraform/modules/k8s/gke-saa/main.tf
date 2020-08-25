locals {
  gcp_resource_count = var.cluster_type == "gcp/gke" ? 1 : 0
}

########################################################
# k8s GKE Service Account Assigner
########################################################
resource "helm_release" "gke_saa" {
  count      = local.gcp_resource_count
  name       = "gke-saa"
  chart      = "odahu-flow-k8s-gke-saa"
  version    = var.odahu_infra_version
  repository = var.helm_repo
  namespace  = var.gke_saa_namespace
  timeout    = var.helm_timeout

  values = [
    templatefile("${path.module}/templates/gke_saa.yaml", {
      default_scopes = join(",", var.gke_saa_default_scopes)
      default_sa     = var.gke_saa_default_sa
      sa_name        = var.gke_saa_sa_name
      image_repo     = var.gke_saa_image_repo
      image_tag      = var.gke_saa_image_tag
      host_port      = var.gke_saa_host_port
      container_port = var.gke_saa_container_port
      name           = var.gke_saa_name
      tolerations    = yamlencode({ tolerations = [{ effect = "NoSchedule", operator = "Exists" }] })
    })
  ]
}
