########################################################
# HELM Init
########################################################
module "helm_init" {
  source           = "../../../../modules/helm_init"
  istio_helm_repo  = var.istio_helm_repo
  legion_helm_repo = var.legion_helm_repo
}
