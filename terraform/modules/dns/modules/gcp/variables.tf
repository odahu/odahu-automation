variable "domain" {
  type    = string
  default = ""
}

variable "managed_zone" {
  type    = string
  default = ""
}

variable "aws_region" {
  type    = string
  default = ""
}

variable "gcp_project_id" {
  type    = string
  default = ""
}

variable "gcp_credentials" {
  type    = string
  default = ""
}

variable "records" {
  type    = list(map(string))
  default = []
}

variable "lb_record" {
  type = map(string)
  default = {
    "name"  = ""
    "value" = ""
    "type"  = ""
    "ttl"   = "300"
  }
}
