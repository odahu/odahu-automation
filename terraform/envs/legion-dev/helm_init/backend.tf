terraform {
  backend "gcs" {
    bucket  = "legion-dev-tfstate"
    prefix  = "/"
  }
}

# terraform {
#   backend "local" {
#     path = "../../../../_tfstate/legion-dev-helm.tfstate"
#   }
# }