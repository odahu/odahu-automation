########################################################
# K8S setup
########################################################

module "tekton" {
  source              = "../../../modules/k8s/tekton"
  helm_repo           = var.helm_repo
  odahu_infra_version = var.odahu_infra_version
}
