variable "examples" {
  type = object({
    examples_urls    = any
    examples_version = string
    deploy_examples  = string
  })
  default = {
    examples_urls    = {}
    examples_version = ""
    deploy_examples  = "false"
  }
  description = "ODAHU Examples configuration"
}

variable "dag_bucket" {
  type        = string
  description = "DAGs bucket name"
}
