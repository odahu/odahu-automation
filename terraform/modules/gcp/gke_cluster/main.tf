locals {
  initial_node_count = length(var.node_locations) == 0 ? lookup(var.node_pools.main, "init_node_count", 1) : floor(lookup(var.node_pools.main, "init_node_count", 2) / length(var.node_locations) + 1)

  default_labels = {
    "project" = "odahu-flow"
    "cluster" = var.cluster_name
  }

  bastion_labels = merge(local.default_labels, var.bastion_labels)
  node_labels    = merge(local.default_labels, var.node_labels)

  node_version = var.node_version == "" ? var.k8s_version : var.node_version
}

########################################################
# GKE Cluster
########################################################

resource "google_container_cluster" "cluster" {
  provider           = google-beta
  project            = var.project_id
  name               = var.cluster_name
  location           = var.location
  network            = var.network
  subnetwork         = var.subnetwork
  min_master_version = var.k8s_version
  node_locations     = var.node_locations

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the default node pool with double
  # initial number of nodes (minimum 4 per location) and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = local.initial_node_count * 2 >= 4 ? local.initial_node_count * 2 : 4

  # Setting an empty username and password explicitly disables basic auth
  master_auth {
    username = ""
    password = ""

    client_certificate_config {
      issue_client_certificate = false
    }
  }

  lifecycle {
    ignore_changes = [
      initial_node_count,
      node_pool,
      network,
      network_policy,
    ]
  }

  vertical_pod_autoscaling {
    enabled = true
  }

  maintenance_policy {
    daily_maintenance_window {
      start_time = "02:00"
    }
  }

  private_cluster_config {
    enable_private_endpoint = false
    enable_private_nodes    = true
    master_ipv4_cidr_block  = var.master_ipv4_cidr_block
  }

  # workaround #2231 issue with master access
  master_authorized_networks_config {
    dynamic "cidr_blocks" {
      iterator = cidr_block
      for_each = var.allowed_ips
      content {
        cidr_block = cidr_block.value
      }
    }
  }

  ip_allocation_policy {
    use_ip_aliases           = true
    cluster_ipv4_cidr_block  = var.pods_cidr
    services_ipv4_cidr_block = var.service_cidr
  }

  addons_config {
    http_load_balancing {
      disabled = true
    }
    horizontal_pod_autoscaling {
      disabled = true
    }
    network_policy_config {
      disabled = true
    }
  }

  resource_labels = local.node_labels
}

########################################################
# Node Pools
########################################################
resource "google_container_node_pool" "cluster_node_pools" {
  for_each           = var.node_pools
  provider           = google-beta
  project            = var.project_id
  name               = substr(replace(each.key, "/[_\\W]/", "-"), 0, 40)
  location           = var.location
  cluster            = var.cluster_name
  initial_node_count = lookup(each.value, "init_node_count", 0)
  depends_on         = [google_container_cluster.cluster]
  version            = local.node_version

  autoscaling {
    min_node_count = lookup(each.value, "min_node_count", "0")
    max_node_count = lookup(each.value, "max_node_count", "2")
  }

  management {
    auto_repair  = false
    auto_upgrade = false
  }

  node_config {
    preemptible     = lookup(each.value, "preemptible", "false")
    machine_type    = lookup(each.value, "machine_type", "n1-standard-2")
    disk_size_gb    = lookup(each.value, "disk_size_gb", "20")
    disk_type       = lookup(each.value, "disk_type", "pd-standard")
    service_account = var.nodes_sa
    image_type      = lookup(each.value, "image", "COS")
    tags            = concat(var.node_gcp_tags, lookup(each.value, "tags", []))

    metadata = {
      disable-legacy-endpoints = "true"
    }

    labels = merge(lookup(each.value, "labels", {}), {
      "project" = "odahu-flow"
    })

    dynamic taint {
      for_each = lookup(each.value, "taints", [])
      content {
        key    = taint.value.key
        value  = taint.value.value
        effect = taint.value.effect
      }
    }

    dynamic guest_accelerator {
      for_each = toset(lookup(each.value, "gpu", []))
      content {
        count = guest_accelerator.value.count
        type  = guest_accelerator.value.type
      }
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/cloud-platform",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }

  lifecycle {
    ignore_changes = [
      version,
    ]
  }
}

########################################################
# SSH keys
########################################################

resource "google_compute_project_metadata_item" "ssh_public_keys" {
  count    = var.bastion_enabled ? 1 : 0
  provider = google-beta
  project  = var.project_id
  key      = "ssh-keys"
  value    = "${var.ssh_user}:${var.ssh_public_key}"
}

########################################################
# Bastion Host
########################################################
resource "google_compute_instance" "gke_bastion" {
  count                     = var.bastion_enabled ? 1 : 0
  name                      = "${var.cluster_name}-${var.bastion_hostname}"
  machine_type              = var.bastion_machine_type
  zone                      = var.zone
  project                   = var.project_id
  allow_stopping_for_update = true
  depends_on                = [google_container_cluster.cluster]

  // Specify the Operating System Family and version.
  boot_disk {
    initialize_params {
      image = "ubuntu-1804-lts"
    }
  }

  tags   = var.bastion_gcp_tags
  labels = local.bastion_labels

  // Define a network interface in the correct subnet.
  network_interface {
    subnetwork         = var.subnetwork
    subnetwork_project = var.project_id
    access_config {
      // Implicit ephemeral IP
    }
  }

  metadata = {
    ssh-keys = "${var.ssh_user}:${var.ssh_public_key}"
  }

  metadata_startup_script = <<SCRIPT
    sed -i '/AllowAgentForwarding/s/^#//g' /etc/ssh/sshd_config && systemctl restart ssh.service
  SCRIPT

  // Necessary scopes for administering kubernetes.
  service_account {
    scopes = ["userinfo-email", "compute-ro", "storage-ro"]
  }
}

# Wait for cluster startup
resource "null_resource" "kubectl_config" {
  triggers = {
    build_number = timestamp()
  }
  provisioner "local-exec" {
    command = "timeout 1200 bash -c 'until curl -sk https://${google_container_cluster.cluster.endpoint}; do sleep 20; done'"
  }
  depends_on = [google_container_node_pool.cluster_node_pools]
}
