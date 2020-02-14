variable "domain" {
  default = ""
  type    = string
}

variable "managed_zone" {
  default = ""
  type    = string
}

variable "gcp_project_id" {
  default = ""
  type    = string
}

variable "gcp_credentials" {
  default = ""
  type    = string
}

variable "records" {
  default = []
  type    = list(map(string))
}
