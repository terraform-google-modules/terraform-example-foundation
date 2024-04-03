terraform {
  backend "gcs" {
    bucket = "UPDATE_ME"
    prefix = "terraform/environments/nonproduction"
  }
}