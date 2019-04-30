# Module providers

provider "kubernetes" {
  config_context_auth_info  = "gke_or2-msq-epmd-legn-t1iylu_us-east1-b_legion-dev"
  config_context_cluster    = "gke_or2-msq-epmd-legn-t1iylu_us-east1-b_legion-dev"
}

########################################################
# HELM Init
########################################################
module "helm_init" {
  source                      = "../../../modules/gcp/helm-init"
}
