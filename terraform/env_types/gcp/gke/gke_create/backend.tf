terraform {
  backend "gcs" {
    prefix = "gke_create"
  }
}

# terraform {
#   backend "local" {
#     path = "../../../../_tfstate/state.tfstate"
#   }
# }
