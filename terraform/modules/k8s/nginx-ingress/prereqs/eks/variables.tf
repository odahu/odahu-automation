variable "cluster_name" {
  default     = "odahuflow"
  description = "Odahuflow cluster name"
}

variable "az_list" {
  default = []
  type    = list(string)
}

variable "aws_lb_subnets" {
  default = []
  type    = list(string)
}
