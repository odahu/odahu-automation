terraform {
  backend "local" {
    path = "../../../../_tfstate/legion-test-k8s.tfstate"
  }
}