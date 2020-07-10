terraform {
  version = "{TERRAFORM_VERSION}"
}

providers {
  aws         = ["2.52.0"]
  azurerm     = ["2.16.0"]
  external    = ["1.2.0"]
  google-beta = ["2.20.2"]
  google      = ["2.20.2"]
  helm        = ["1.0.0"]
  kubernetes  = ["1.11.0"]
  local       = ["1.4.0"]
  null        = ["2.1.2"]
  random      = ["2.2.1"]
  template    = ["2.1.2"]
  tls         = ["2.1.1"]
}
