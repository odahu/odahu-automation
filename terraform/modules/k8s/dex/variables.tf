##################
# Common
##################
variable "project_id" {
  description = "Target project id"
}
variable "cluster_name" {
  default     = "legion"
  description = "Legion cluster name"
}
variable "aws_profile" {
  description = "AWS profile name"
}
variable "aws_credentials_file" {
  description = "AWS credentials file location"
}
variable "zone" {
  description = "Default zone"
}
variable "region" {
  description = "Region of resources"
}
variable "region_aws" {
  description = "Region of AWS resources"
}
variable "legion_helm_repo" {
  description = "Legion helm repo"
}
variable "root_domain" {
  description = "Legion cluster root domain"
}
variable "dns_zone_name" {
  description = "Cluster root DNS zone name"
}
variable "legion_infra_version" {
  description = "Legion infra release version"
}

##################
# Auth setup
##################
variable "dex_replicas" {
  default = 1
  description = "Number of dex replicas"
}
variable "github_org_name" {
  description = "Github Organization for dex authentication"
}
variable "dex_github_clientid" {
  description = "Github Organization clientID"
}
variable "dex_github_clientSecret" {
  description = "Github Organization client Secret"
}
variable "dex_client_secret" {
  description = "Dex default client Secret"
}
variable "dex_client_id" {
  description = "Dex default client Secret"
}
variable "dex_static_user_email" {
  description = "Dex static user email"
}
variable "dex_static_user_pass" {
  description = "Dex static user pass"
}
variable "dex_static_user_hash" {
  description = "Dex static user hash"
}
variable "dex_static_user_name" {
  description = "Dex static user username"
}
variable "dex_static_user_id" {
  description = "Dex static user user id"
}
variable "dex_cookie_expire" {
  default = "3600"
  description = "Dex oauth2 cookie expiration"
}
variable "oauth2_helm_chart_version" {
  default = "0.12.2"
  description = "version of oauth2 proxy helm chart"
}
variable "dex_cookie_secret" {
  description = "oauth2 secret for cookies"
}
variable "oauth2_image_tag" {
  default = "v3.2.0-amd64"
  description = "image tag of oauth2 proxy"
}