# terraform {
#   backend "gcs" {
#     bucket  = "legion-dev-tfstate"
#     prefix  = "/"
#   }
# }

terraform {
  backend "local" {
    path = "../../../../_tfstate/legion-dev-k8s.tfstate"
  }
}