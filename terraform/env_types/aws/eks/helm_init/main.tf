########################################################
# HELM Init
########################################################
module "helm_init" {
  source          = "../../../../modules/helm_init"
  helm_repo       = var.helm_repo
  istio_helm_repo = var.istio_helm_repo
}
