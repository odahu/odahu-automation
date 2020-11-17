locals {
  managed_zone = length(var.managed_zone) == 0 ? google_dns_managed_zone.this[0].name : data.google_dns_managed_zone.this[0].name
  domain       = length(var.managed_zone) == 0 ? google_dns_managed_zone.this[0].dns_name : data.google_dns_managed_zone.this[0].dns_name
  records      = { for rec in var.records : md5("${rec.name}_${rec.value}") => rec if rec.value != "null" }
}

resource "google_dns_managed_zone" "this" {
  count = length(var.managed_zone) == 0 ? 1 : 0

  project     = var.gcp_project_id
  name        = replace(var.domain, ".", "-")
  dns_name    = "${var.domain}."
  description = "Managed by Terraform"
}

data "google_dns_managed_zone" "this" {
  count = length(var.managed_zone) == 0 ? 0 : 1

  project = var.gcp_project_id
  name    = var.managed_zone
}

resource "google_dns_record_set" "this" {
  for_each = local.records

  project      = var.gcp_project_id
  name         = "${lookup(each.value, "name")}.${local.domain}"
  type         = lookup(each.value, "type", "A")
  ttl          = lookup(each.value, "ttl", 300)
  managed_zone = local.managed_zone
  rrdatas      = [lookup(each.value, "value")]
}

resource "google_dns_record_set" "lb" {
  project      = var.gcp_project_id
  name         = "${var.lb_record.name}.${local.domain}"
  type         = var.lb_record.type
  ttl          = var.lb_record.ttl
  managed_zone = local.managed_zone
  rrdatas      = [var.lb_record.value]
}
