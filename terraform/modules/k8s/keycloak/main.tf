provider "helm" {
  version         = "v0.10.0"
  install_tiller  = false
}

########################################################
# Auth setup
########################################################

# Keycloak
data "helm_repository" "codecentric" {
    name = "codecentric"
    url  = "${var.codecentric_helm_repo}"
}

data "template_file" "keycloak_values" {
  template = "${file("${path.module}/templates/keycloak.yaml")}"
  vars = {
    cluster_name              = "${var.cluster_name}"
    root_domain               = "${var.root_domain}"
    keycloak_image_repository = "${var.keycloak_image_repository}"
    keycloak_image_tag        = "${var.keycloak_image_tag}"
    keycloak_admin_user       = "${var.keycloak_admin_user}"
    keycloak_admin_pass       = "${var.keycloak_admin_pass}"
    keycloak_db_user          = "${var.keycloak_db_user}"
    keycloak_db_pass          = "${var.keycloak_db_pass}"
    keycloak_pg_user          = "${var.keycloak_pg_user}"
    keycloak_pg_pass          = "${var.keycloak_pg_pass}"
  }
}

resource "helm_release" "keycloak" {
    name        = "keycloak"
    chart       = "codecentric/keycloak"
    version     = "${var.keycloak_helm_chart_version}"
    namespace   = "kube-system"
    repository  = "${data.helm_repository.codecentric.metadata.0.name}"

    values = [
      "${data.template_file.keycloak_values.rendered}"
    ]

    depends_on  = ["data.helm_repository.codecentric"]
}