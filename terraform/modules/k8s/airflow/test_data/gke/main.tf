locals {
  wine_data_dirs = ["data", "input"]
  wine_data_url  = replace(var.wine_data_url, "{EXAMPLES_VERSION}", var.examples_version)
}

# Download WINE Data
resource "null_resource" "download_wine_data" {
  triggers = {
    build_number = timestamp()
  }

  provisioner "local-exec" {
    command = "curl ${local.wine_data_url} -o /tmp/wine-quality.csv"
  }
}

# Upload WINE data
resource "google_storage_bucket_object" "wine_data" {
  count      = length(local.wine_data_dirs)
  name       = "${element(local.wine_data_dirs, count.index)}/wine-quality.csv"
  source     = "/tmp/wine-quality.csv"
  bucket     = var.wine_bucket
  depends_on = [null_resource.download_wine_data]
}
