provider "google" {
  version     = "~> 2.2"
  region      = "${var.region}"
  zone        = "${var.zone}"
  project     = "${var.project_id}"
}


# Get GCP metadata from local gcloud config
data "google_client_config" "gcloud" {}

########################################################
# GKE Cluster
########################################################

resource "google_container_cluster" "cluster" {
  project               = "${var.project_id}"
  name                  = "${var.cluster_name}"
  location              = "${var.location}"
  network               = "${var.network}"
  subnetwork            = "${var.subnetwork}"
  min_master_version    = "${var.k8s_version}"
  
  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count = 1

  # Setting an empty username and password explicitly disables basic auth
  master_auth {
    username = ""
    password = ""
  }

  lifecycle {
    ignore_changes  = ["node_count", "master_auth", "network"]
  }

  private_cluster_config {
    enable_private_endpoint = false
    enable_private_nodes    = true
    master_ipv4_cidr_block  = "172.25.100.0/28"
  }
  # workaround #2231 issue with master access
  master_authorized_networks_config {
    cidr_blocks = [
      {
        cidr_block    = "${var.master_authorized_network}"
        display_name  = "default-access"
      },
    ]
  }
  ip_allocation_policy {
    use_ip_aliases   = true
  }

  network_policy {
    enabled  = true
    provider = "CALICO"
  }

  addons_config {
    http_load_balancing {
      disabled = false
    }
    kubernetes_dashboard {
      disabled = false
    }
    horizontal_pod_autoscaling {
      disabled = false
    }
    network_policy_config {
      disabled = false
    }
  }

  resource_labels {
    "project"       = "legion"
    "cluster_name"  = "${var.cluster_name}"
  }

}

########################################################
# Node Pool
########################################################

resource "google_container_node_pool" "cluster_nodes" {
  project               = "${var.project_id}"
  name                  = "${var.cluster_name}-node-pool"
  location              = "${var.location}"
  cluster               = "${var.cluster_name}"
  initial_node_count    = 1
  depends_on            = ["google_container_cluster.cluster"]
  version               = "${var.node_version}"

  autoscaling {
    min_node_count = "${var.gke_num_nodes_min}"
    max_node_count = "${var.gke_num_nodes_max}"
  }

  management {
    auto_repair  = false
    auto_upgrade = false
  }

  node_config {
    preemptible      = false
    machine_type     = "${var.gke_node_machine_type}"
    disk_size_gb     = "${var.node_disk_size_gb}"
    service_account  = "${var.nodes_sa}"
    image_type = "COS"

    metadata {
      disable-legacy-endpoints = "true"
    }

    labels {
      "project" = "legion"
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }
}


########################################################
# Bastion Host
########################################################

resource "google_compute_instance" "gke_bastion" {
  name                      = "${var.bastion_hostname}"
  machine_type              = "${var.bastion_machine_type}"
  zone                      = "${var.zone}"
  project                   = "${var.project_id}"
  tags                      = "${var.bastion_tags}"
  allow_stopping_for_update = true
  depends_on                = ["google_container_cluster.cluster"]

  boot_disk {
    initialize_params {
      image = "ubuntu-1804-lts"
    }
  }

  network_interface {
    subnetwork = "${var.subnetwork}"
  }

  // Necessary scopes for administering kubernetes.
  service_account {
    scopes = ["userinfo-email", "compute-ro", "storage-ro"]
  }
}