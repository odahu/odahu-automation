provider "google" {
  version   = "~> 1.16"
  project   = "${var.project_id}"
  region    = "${var.region}"
}

module "gcp" {
  source  = "../../modules/gcp"

  project           = "${var.project_id}"
  region            = "${var.region}"
  cluster_name      = "${var.cluster_name}"
  cluster_location  = "${var.cluster_location}"
  # ip_cidr_range     = "${var.ip_cidr_range}"
  # zones                 = "${var.zones}"
  # gke_num_nodes_min     = "${var.gke_num_nodes_min}"
  # gke_num_nodes_max     = "${var.gke_num_nodes_max}"
  # gke_node_machine_type = "${var.gke_node_machine_type}"
  # ip_range_pods         = "${var.ip_range_pods}"
  # ip_range_services     = "${var.ip_range_services}"
}

