locals {
  env_business_unit_folder_name = "${folder_prefix}-${var.env}-${var.business_code}"
}

resource "google_folder" "env_business_unit" {
  display_name = local.env_business_unit_folder_name
  parent       = "folders/${folder_prefix}-${var.env}"
}
