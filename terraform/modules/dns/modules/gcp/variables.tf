variable "domain" {
  default = ""
}

variable "managed_zone" {
  default = ""
}

variable "project_id" {
  default = ""
}

variable "records" {
  default = []
  type    = list
}

variable "tfstate_bucket" {
}
