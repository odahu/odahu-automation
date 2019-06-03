terraform {
  backend "gcs" {
    bucket  = "legion-dev-tfstate"
    prefix  = "/helm_init/"
  }
}

# terraform {
#   backend "local" {
#     path = "../../../../_tfstate/legion-dev-helm.tfstate"
#   }
# }