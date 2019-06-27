terraform {
  backend "gcs" {
    prefix  = "helm_init"
  }
}

# terraform {
#   backend "local" {
#     path = "../../../../_tfstate/legion-dev-helm.tfstate"
#   }
# }