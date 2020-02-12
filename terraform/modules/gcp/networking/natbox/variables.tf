variable "cluster_name" {
  default     = "odahuflow"
  description = "Odahuflow cluster name"
}

variable "gcp_project_id" {
  description = "Target GCP project ID"
}

variable "gcp_zone" {
  description = "Target GCP zone"
}

variable "ssh_user" {
  default     = "ubuntu"
  description = "default ssh user"
}

variable "ssh_public_key" {
  description = "SSH public key"
}

variable "gke_subnet" {
  description = "Name of GKE nodes subnet in `gke_network` VPC"
}

variable "pods_cidr" {
  description = "GKE pods CIDR"
}

variable "dmz_dest_cidr" {
  description = "Network CIDR that should be reachable through natbox host"
}

variable "dmz_subnet" {
  description = "Name of the DMZ subnet (routed to internal resources)"
}

variable "dmz_natbox_enabled" {
  default     = false
  type        = bool
  description = "Flag to install natbox host or not"
}

variable "dmz_natbox_machine_type" {
  default = "custom-2-4096"
}

variable "dmz_natbox_hostname" {
  default     = "dmz-natbox"
  description = "DMZ natbox host name"
}

variable "gke_gcp_tags" {
  default     = []
  description = "GKE nodes GCP network tags"
  type        = list(string)
}

variable "bastion_gcp_tags" {
  default     = []
  description = "Bastion host GCP network tags"
  type        = list(string)
}

variable "dmz_natbox_gcp_tags" {
  default     = []
  description = "DMZ natbox host GCP network tags"
  type        = list(string)
}

variable "dmz_natbox_labels" {
  default     = {}
  description = "DMZ natbox host GCP labels"
  type        = map(string)
}
