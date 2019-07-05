provider "helm" {
  version         = "0.9.1"
  install_tiller  = false
}

data "helm_repository" "legion" {
    name = "legion_github"
    url  = "${var.legion_helm_repo}"
}

########################################################
# Prometheus monitoring
########################################################
data "helm_repository" "codecentric" {
    name = "codecentric"
    url  = "${var.codecentric_helm_repo}"
}

data "template_file" "keycloak_values" {
  template = "${file("${path.module}/templates/keycloak.yaml")}"
  vars = {
    cluster_name              = "${var.cluster_name}"
    root_domain               = "${var.root_domain}"
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
    version     = "4.14.0"
    namespace   = "kube-system"
    repository  = "${data.helm_repository.codecentric.metadata.0.name}"

    values = [
      "${data.template_file.keycloak_values.rendered}"
    ]
}

# Keycloak gatekeeper proxy
data "helm_repository" "gatekeeper" {
    name = "gabibbo97"
    url  = "${var.gatekeeper_helm_repo}"
}

data "template_file" "gatekeeper_values" {
  template = "${file("${path.module}/templates/gatekeeper.yaml")}"
  vars = {
    cluster_name              = "${var.cluster_name}"
    root_domain               = "${var.root_domain}"
  }
}

resource "helm_release" "gatekeeper" {
    name        = "keycloak-gatekeeper"
    chart       = "gabibbo97/keycloak-gatekeeper"
    version     = "1.2.1"
    namespace   = "kube-system"
    repository  = "${data.helm_repository.gatekeeper.metadata.0.name}"

    values = [
      "${data.template_file.gatekeeper_values.rendered}"
    ]
}
