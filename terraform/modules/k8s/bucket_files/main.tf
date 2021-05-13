locals {
  dag_bucket = var.dag_bucket
  examples_urls = {for remotePath, templateHttpLink in var.examples_urls : remotePath => replace(templateHttpLink, "{EXAMPLES_VERSION}", var.examples_version)}
}

data "http" "links" {
  for_each = toset(values(local.examples_urls))
  url = each.value
}

resource "local_file" "files" {
  for_each = local.examples_urls
  content  = data.http.links[each.value].body
  filename = "/tmp/composer_data/${basename(each.key)}"
}

resource "google_storage_bucket_object" "files" {
  for_each   = local.examples_urls
  name       = "dags/${each.key}"
  source     = "/tmp/composer_data/${basename(each.key)}"
  bucket     = local.dag_bucket
  depends_on = [local_file.files]
}
