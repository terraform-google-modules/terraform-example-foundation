module "env_secrets" {
  source                      = "terraform-google-modules/project-factory/google"
  version                     = "~> 10.0"
  random_project_id           = "true"
  impersonate_service_account = var.terraform_service_account
  default_service_account     = "deprivilege"
  name                        = "${var.project_prefix}-${var.environment_code}-secrets"
  org_id                      = var.org_id
  billing_account             = var.billing_account
  folder_id                   = google_folder.env.id
  disable_services_on_destroy = false
  activate_apis               = ["logging.googleapis.com", "secretmanager.googleapis.com", "cloudkms.googleapis.com"]

  labels = {
    environment       = var.env
    application_name  = "env-secrets"
    billing_code      = "1234"
    primary_contact   = "example1"
    secondary_contact = "example2"
    business_code     = "abcd"
    env_code          = var.environment_code
  }
  budget_alert_pubsub_topic   = var.secret_project_alert_pubsub_topic
  budget_alert_spent_percents = var.secret_project_alert_spent_percents
  budget_amount               = var.secret_project_budget_amount
}