locals {
  # split `domain` variable to zone_name and root_domain parts, e.x.: mydomain.test.com will split to zone_name="mydomain" & root_domain="test.com"
  parsed = length(var.domain) == 0 ? {} : regex("^(?P<zone_name>[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?).(?P<root_domain>.*)", var.domain)

  zone_name    = lookup(local.parsed, "zone_name", "")
  root_domain  = lookup(local.parsed, "root_domain", "")
  managed_zone = length(var.managed_zone) == 0 ? google_dns_managed_zone.this[0].name : data.google_dns_managed_zone.this[0].name
  domain       = length(var.managed_zone) == 0 ? google_dns_managed_zone.this[0].dns_name : data.google_dns_managed_zone.this[0].dns_name
  records      = { for rec in var.records : md5("${rec.name}_${rec.value}") => rec }
  records_str  = join(" ", [ for rec in var.records : rec.name ])
}

resource "google_dns_managed_zone" "this" {
  count = length(var.managed_zone) == 0 ? 1 : 0

  project     = var.project_id
  name        = replace(var.domain, ".", "-")
  dns_name    = "${var.domain}."
  description = "Managed by Terraform"
}

data "google_dns_managed_zone" "this" {
  count = length(var.managed_zone) == 0 ? 0 : 1

  project = var.project_id
  name    = var.managed_zone
}

resource "google_dns_record_set" "this" {
  for_each = local.records

  project      = var.project_id
  name         = "${lookup(each.value, "name")}.${local.domain}"
  type         = lookup(each.value, "type", "A")
  ttl          = lookup(each.value, "ttl", 300)
  managed_zone = local.managed_zone
  rrdatas      = [lookup(each.value, "value")]
}

resource "null_resource" "wait_for_dns" {
     build_number = timestamp()
   }
   provisioner "local-exec" {
    command = "timeout 600 bash -c 'for NAME in ${local.records_str}; do until dig +short $NAME.${local.domain}; do sleep 5; done ; done'"
   }
   depends_on = [google_dns_record_set.this]
 }

