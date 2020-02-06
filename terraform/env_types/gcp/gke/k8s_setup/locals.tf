locals {
  network_name = var.vpc_name == "" ? "${var.cluster_name}-vpc" : var.vpc_name
}
