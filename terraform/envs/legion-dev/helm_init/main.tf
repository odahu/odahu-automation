########################################################
# HELM Init
########################################################
module "helm_init" {
  source                      = "../../../modules/helm_init"
  config_context_auth_info    = "${var.config_context_auth_info}"
  config_context_cluster      = "${var.config_context_cluster}"
  project_id                  = "${var.project_id}"
  cluster_name                = "${var.cluster_name}"
  zone                        = "${var.zone}"
}
