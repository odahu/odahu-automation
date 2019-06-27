terraform {
  backend "gcs" {
    prefix  = "legion"
  }
}

# terraform {
#   backend "local" {
#     path = "../../../../_tfstate/legion-dev-legion.tfstate"
#   }
# }