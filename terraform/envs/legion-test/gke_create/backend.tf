terraform {
  backend "gcs" {
    bucket  = "legion-test-tfstate"
    prefix  = "gke_create"
  }
}
