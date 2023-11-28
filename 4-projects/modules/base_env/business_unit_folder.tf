locals {
  env_business_unit_folder_name = "${var.folder_prefix}-${var.env}-${var.business_code}"
}

resource "google_folder" "env_business_unit" {
  display_name = local.env_business_unit_folder_name
  parent       = local.env_folder_name
}
