terraform {
  backend "gcs" {
    bucket  = "legion-dev-tfstate"
    prefix  = "legion"
  }
}
