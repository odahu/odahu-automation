terraform {
  backend "gcs" {
    bucket  = "legion-dev-tfstate"
    prefix  = "legion"
  }
}

# terraform {
#   backend "local" {
#     path = "../../../../_tfstate/legion-dev-legion.tfstate"
#   }
# }