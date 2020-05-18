terraform {
  backend "gcs" {
    bucket = "STATE_BUCKET"
    prefix = "terraform/bootstrap/state"
  }
}
