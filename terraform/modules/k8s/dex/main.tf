provider "helm" {
  version         = "0.9.1"
  install_tiller  = false
}

provider "google" {
  version     = "~> 2.2"
  region      = "${var.region}"
  zone        = "${var.zone}"
  project     = "${var.project_id}"
}

provider "aws" {
  version                   = "2.13"
  region                    = "${var.region_aws}"
  shared_credentials_file   = "${var.aws_credentials_file}"
  profile                   = "${var.aws_profile}"
}

data "helm_repository" "legion" {
    name = "legion_github"
    url  = "${var.legion_helm_repo}"
}

########################################################
# Auth setup
########################################################

# Dex
resource "google_compute_address" "dex_lb_address" {
  name              = "${var.cluster_name}-dex"
  region            = "${var.region}"
  address_type      = "EXTERNAL"
}

resource "google_dns_record_set" "dex_lb" {
  name          = "dex.${var.cluster_name}.${var.root_domain}."
  type          = "A"
  ttl           = 300
  managed_zone  = "${var.dns_zone_name}"
  rrdatas       = ["${google_compute_address.dex_lb_address.address}"]
}


data "template_file" "dex_values" {
  template = "${file("${path.module}/templates/dex.yaml")}"
  vars = {
    cluster_name              = "${var.cluster_name}"
    root_domain               = "${var.root_domain}"
    dex_replicas              = "${var.dex_replicas}"
    dex_github_clientid       = "${var.dex_github_clientid}"
    dex_github_clientSecret   = "${var.dex_github_clientSecret}"
    github_org_name           = "${var.github_org_name}"
    dex_client_id             = "${var.dex_client_id}"
    dex_client_secret         = "${var.dex_client_secret}"
    dex_static_user_email     = "${var.dex_static_user_email}"
    dex_static_user_pass      = "${var.dex_static_user_pass}"
    dex_static_user_hash      = "${var.dex_static_user_hash}"
    dex_static_user_name      = "${var.dex_static_user_name}"
    dex_static_user_id        = "${var.dex_static_user_id}"
    dex_external_ip           = "${google_compute_address.dex_lb_address.address}"
  }
}

resource "helm_release" "dex" {
    name            = "dex"
    chart           = "legion_github/dex"
    version         = "${var.legion_infra_version}"
    namespace       = "kube-system"
    repository      = "${data.helm_repository.legion.metadata.0.name}"
    recreate_pods   = "true"

    values = [
      "${data.template_file.dex_values.rendered}"
    ]

    # set {
    #     name    = "service.loadBalancerSourceRanges"
    #     value   = "{${join(",", var.allowed_ips)}}"
    # }
}

# Oauth2 proxy
data "template_file" "oauth2-proxy_values" {
  template = "${file("${path.module}/templates/oauth2-proxy.yaml")}"
  vars = {
    cluster_name              = "${var.cluster_name}"
    root_domain               = "${var.root_domain}"
    github_org_name           = "${var.github_org_name}"
    client_secret             = "${var.dex_client_secret}"
    client_id                 = "${var.dex_client_id}"
    dex_cookie_expire         = "${var.dex_cookie_expire}"
  }
}

resource "helm_release" "oauth2-proxy" {
    name            = "oauth2-proxy"
    chart           = "legion_github/oauth2-proxy"
    version         = "${var.legion_infra_version}"
    namespace       = "kube-system"
    repository      = "${data.helm_repository.legion.metadata.0.name}"
    recreate_pods   = "true"

    values = [
      "${data.template_file.oauth2-proxy_values.rendered}"
    ]
}
