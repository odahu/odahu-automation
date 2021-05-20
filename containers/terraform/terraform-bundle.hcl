terraform {
  version = "{TERRAFORM_VERSION}"
}

providers {
  aws         = { versions = ["2.70.0"] }
  azurerm     = { versions = ["2.29.0"] }
  external    = { versions = ["1.2.0"] }
  google-beta = { versions = ["3.68.0"] }
  google      = { versions = ["3.68.0"] }
  helm        = { versions = ["1.3.1"] }
  kubernetes  = { versions = ["1.13.2"] }
  local       = { versions = ["1.4.0"] }
  null        = { versions = ["2.1.2"] }
  random      = { versions = ["2.2.1"] }
  template    = { versions = ["2.1.2"] }
  tls         = { versions = ["2.1.1"] }
}
