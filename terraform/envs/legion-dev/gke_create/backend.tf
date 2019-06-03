terraform {
  backend "gcs" {
    bucket  = "legion-dev-tfstate"
    prefix  = "/gke_create/"
  }
}

# terraform {
#   backend "local" {
#     path = "../../../../_tfstate/legion-dev-gke.tfstate"
#   }
# }