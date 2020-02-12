data "google_compute_subnetwork" "dmz_subnet" {
  name = var.dmz_subnet
}

data "google_compute_subnetwork" "gke_subnet" {
  name = var.gke_subnet
}

locals {
  default_labels = {
    "project" = "odahu-flow"
    "cluster" = var.cluster_name
  }

  dmz_natbox_labels   = merge(local.default_labels, var.dmz_natbox_labels)
  dmz_natbox_gcp_tags = length(var.dmz_natbox_gcp_tags) == 0 ? ["${var.cluster_name}-dmz-natbox"] : var.dmz_natbox_gcp_tags

  gke_dmz_peering_enabled = data.google_compute_subnetwork.gke_subnet.network != data.google_compute_subnetwork.dmz_subnet.network
}

resource "google_compute_instance" "dmz_natbox" {
  count                     = var.dmz_natbox_enabled ? 1 : 0
  name                      = "${var.cluster_name}-${var.dmz_natbox_hostname}"
  machine_type              = var.dmz_natbox_machine_type
  zone                      = var.gcp_zone
  project                   = var.gcp_project_id
  allow_stopping_for_update = true
  can_ip_forward            = true

  boot_disk {
    initialize_params {
      image = "ubuntu-1804-lts"
    }
  }

  tags   = local.dmz_natbox_gcp_tags
  labels = local.dmz_natbox_labels

  network_interface {
    subnetwork         = var.dmz_subnet
    subnetwork_project = var.gcp_project_id
  }

  metadata = {
    ssh-keys = "${var.ssh_user}:${var.ssh_public_key}"
  }

  metadata_startup_script = <<SCRIPT
    sed -i '/AllowAgentForwarding/s/^#//g' /etc/ssh/sshd_config && \
    systemctl restart ssh.service
    sed -i '/net.ipv4.ip_forward/s/^#//g' /etc/sysctl.conf && \
    systemctl restart systemd-sysctl.service

    iptables -t nat -A POSTROUTING -j MASQUERADE -s ${data.google_compute_subnetwork.gke_subnet.ip_cidr_range} -d ${var.dmz_dest_cidr}
    iptables -t nat -A POSTROUTING -j MASQUERADE -s ${var.pods_cidr} -d ${var.dmz_dest_cidr}
  SCRIPT

  service_account {
    scopes = ["userinfo-email", "compute-ro", "storage-ro"]
  }
}

resource "google_compute_route" "gke_to_dmz" {
  count      = var.dmz_natbox_enabled ? 1 : 0
  name       = substr("${var.cluster_name}-gke-to-dmz", 0, 62)
  network    = data.google_compute_subnetwork.gke_subnet.network
  dest_range = var.dmz_dest_cidr
  priority   = 800
  tags       = concat(var.gke_gcp_tags, var.bastion_gcp_tags)

  next_hop_instance      = google_compute_instance.dmz_natbox[0].name
  next_hop_instance_zone = google_compute_instance.dmz_natbox[0].zone
}

# Firewall rule to allow traffic between nodes in GKE subnet and NATbox host
resource "google_compute_firewall" "gke_to_dmz" {
  count   = var.dmz_natbox_enabled ? 1 : 0
  project = var.gcp_project_id
  name    = substr("${var.cluster_name}-gke-to-dmz", 0, 62)
  network = data.google_compute_subnetwork.gke_subnet.network
  source_ranges = [
    var.pods_cidr,
    data.google_compute_subnetwork.gke_subnet.ip_cidr_range,
    data.google_compute_subnetwork.dmz_subnet.ip_cidr_range
  ]

  target_tags = concat(local.dmz_natbox_gcp_tags, var.gke_gcp_tags, var.bastion_gcp_tags)

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
  }

  allow {
    protocol = "udp"
  }

  depends_on = [google_compute_route.gke_to_dmz[0]]
}
