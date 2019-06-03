terraform {
  backend "gcs" {
    bucket  = "legion-dev-tfstate"
    prefix  = "/k8s_setup/"
  }
}

# terraform {
#   backend "local" {
#     path = "../../../../_tfstate/legion-dev-k8s.tfstate"
#   }
# }