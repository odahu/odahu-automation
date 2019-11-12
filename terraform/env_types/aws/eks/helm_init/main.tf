########################################################
# HELM Init
########################################################
module "helm_init" {
  source           = "../../../../modules/helm_init"
  istio_helm_repo  = var.istio_helm_repo
  helm_repo = var.helm_repo
}
