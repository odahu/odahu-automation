provider "google" {
  version                   = "~> 2.2"
  region                    = "${var.region}"
  zone                      = "${var.zone}"
  project                   = "${var.project_id}"
}

provider "aws" {
  region                    = "${var.region_aws}"
  shared_credentials_file   = "${var.aws_credentials_file}"
  profile                   = "${var.aws_profile}"
}

########################################################
# GKE Cluster
########################################################

resource "google_container_cluster" "cluster" {
  project                   = "${var.project_id}"
  name                      = "${var.cluster_name}"
  location                  = "${var.location}"
  network                   = "${var.network}"
  subnetwork                = "${var.subnetwork}"
  min_master_version        = "${var.k8s_version}"
  
  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool  = true
  initial_node_count        = 1

  # Setting an empty username and password explicitly disables basic auth
  master_auth {
    username  = ""
    password  = ""

    client_certificate_config {
      issue_client_certificate = false
    }
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
        cidr_block    = "${var.allowed_ips}"
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
      disabled = true
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

# Configure kubectl
# TODO add startup timeout
# resource "null_resource" "kubectl_config" {
#   provisioner "local-exec" {
#     command = "gcloud container clusters get-credentials ${var.cluster_name} --zone ${var.zone} --project ${var.project_id}"
#   }
# }

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
    image_type       = "COS"

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
# SSH keys
########################################################
# TODO: consider gcs as secrets storage. The problem is missed object body in terraform data resource
# data "google_storage_bucket_object" "ssh_public_key" {
#   bucket   = "${var.secrets_storage}"
#   name     = "${var.cluster_name}.pub"
# }

data "aws_s3_bucket_object" "ssh_public_key" {
  bucket  = "${var.secrets_storage}"
  key     = "${var.cluster_name}/ssh/${var.cluster_name}.pub"
}

resource "google_compute_project_metadata_item" "ssh_public_keys" {
  key     = "ssh-keys"
  value   = "${var.ssh_user}:${data.aws_s3_bucket_object.ssh_public_key.body}"
}

########################################################
# Bastion Host
########################################################
resource "google_compute_instance" "gke_bastion" {
  name                      = "${var.bastion_hostname}"
  machine_type              = "${var.bastion_machine_type}"
  zone                      = "${var.zone}"
  project                   = "${var.project_id}"
  allow_stopping_for_update = true
  depends_on                = ["google_container_cluster.cluster"]

  // Specify the Operating System Family and version.
  boot_disk {
    initialize_params {
      image = "ubuntu-1804-lts"
    }
  }

  tags = ["${var.bastion_tags}"]

  // Define a network interface in the correct subnet.
  network_interface {
    subnetwork = "${var.subnetwork}"

    access_config {
      // Implicit ephemeral IP
    }
  }

  metadata {
    ssh-keys = "${var.ssh_user}:${data.aws_s3_bucket_object.ssh_public_key.body}"
  }

  metadata_startup_script = "sed -i '/AllowAgentForwarding/s/^#//g' /etc/ssh/sshd_config && service sshd restart"

  // Necessary scopes for administering kubernetes.
  service_account {
    scopes = ["userinfo-email", "compute-ro", "storage-ro"]
  }
}

########################################################
#  DNS records
########################################################

# TODO: consider local dns for DEX
# local DNS zone
# data "google_compute_network" "vpc" {
#   name = "${var.network}"
# }

# resource "google_dns_managed_zone" "local_zone" {
#   name          = "${var.cluster_name}-local"
#   dns_name      = "local-legion-dev.gcp.epm.kharlamov.biz."
#   description   = "Local ${var.cluster_name} zone"
#   visibility    = "private"
#   private_visibility_config {
#     networks {
#       network_url =  "https://www.googleapis.com/compute/v1/projects/${var.project_id}/global/networks/${var.network}"
#     }
#   }
#   labels = {
#     project = "legion"
#     cluster = "${var.cluster_name}"
#   }
#   # depends_on    = ["google_compute_network.vpc"]
# }

resource "google_dns_record_set" "gke_bastion" {
  name          = "bastion.${var.cluster_name}.${var.root_domain}."
  type          = "A"
  ttl           = 300
  managed_zone  = "${var.dns_zone_name}"
  rrdatas       = ["${google_compute_instance.gke_bastion.network_interface.0.access_config.0.nat_ip}"]
}

resource "google_dns_record_set" "gke_api" {
  name          = "api.${var.cluster_name}.${var.root_domain}."
  type          = "A"
  ttl           = 300
  managed_zone  = "${var.dns_zone_name}"
  rrdatas       = ["${google_container_cluster.cluster.endpoint}"]
}
