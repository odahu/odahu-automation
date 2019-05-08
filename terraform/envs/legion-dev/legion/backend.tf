# terraform {
#   backend "gcs" {
#     bucket  = "legion-dev-tfstate"
#     prefix  = "/"
#     credentials="or2-msq-epmd-legn-t1iylu-d264adcb8ffd.json"
#   }
# }

terraform {
  backend "local" {
    path = "../../../../_tfstate/legion-dev-legion.tfstate"
  }
}