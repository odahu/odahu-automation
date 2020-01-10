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
  type    = list(map(string))
}

variable "tfstate_bucket" {
}
