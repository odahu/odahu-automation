########################################################
# HELM Init
########################################################
module "helm_init" {
  source                   = "../../../../modules/helm_init"
  legion_helm_repo         = var.legion_helm_repo
  istio_helm_repo          = var.istio_helm_repo
  tiller_image             = var.tiller_image
}