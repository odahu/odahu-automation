provider "helm" {
  version         = "v0.10.0"
  install_tiller  = false
}

provider "google" {
  version = "~> 2.2"
  region  = var.region
  zone    = var.zone
  project = var.project_id
}

########################################################
# Nginx Ingress
########################################################
resource "google_compute_address" "ingress_lb_address" {
  name         = "${var.cluster_name}-ingress-main"
  region       = var.region
  address_type = "EXTERNAL"
}

resource "google_dns_record_set" "ingress_lb" {
  name         = "*.${var.cluster_name}.${var.root_domain}."
  type         = "A"
  ttl          = 300
  managed_zone = var.dns_zone_name
  rrdatas      = [google_compute_address.ingress_lb_address.address]
}

# Whitelist allowed_ips and cluster NAT ip on the cluster ingress
data "google_compute_address" "nat_gw_ip" {
  name = "${var.cluster_name}-nat-gw"
}

resource "helm_release" "nginx-ingress" {
  name      = "nginx-ingress"
  chart     = "stable/nginx-ingress"
  namespace = "kube-system"
  version   = "0.20.1"
  set {
    name  = "defaultBackend.service.type"
    value = "LoadBalancer"
  }
  set { 
    name      = "controller.config.proxy-buffer-size" 
    value     = "256k" 
  } 
  set {
    name  = "controller.service.loadBalancerIP"
    value = google_compute_address.ingress_lb_address.address
  }
  depends_on = [google_compute_address.ingress_lb_address]
}

resource "google_compute_firewall" "ingress_access" {
  name          = "${var.cluster_name}-ingress-access"
  network       = var.network_name
  source_ranges = var.allowed_ips
  target_tags   = ["${var.cluster_name}-gke-node"]

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }
}

resource "google_compute_firewall" "auth_loop_access" {
  name          = "${var.cluster_name}-auth-access"
  network       = var.network_name
  source_ranges = ["${data.google_compute_address.nat_gw_ip.address}/32"]
  target_tags   = ["${var.cluster_name}-gke-node"]

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }
}

# Remove default nginx-ingress fw rules created by controller
resource "null_resource" "ingress_fw_cleanup" {
  triggers = {
    build_number = timestamp()
  }
  provisioner "local-exec" {
    command = "gcloud compute firewall-rules list --filter='name:k8s-fw- AND network:${var.network_name}' --format='value(name)' --project='${var.project_id}'| while read i; do if (gcloud compute firewall-rules describe --project='${var.project_id}' $i |grep -q 'kube-system/dex\\|kube-system/nginx-ingress'); then gcloud compute firewall-rules delete $i --quiet; fi; done"
  }
  depends_on = [helm_release.nginx-ingress]
}

