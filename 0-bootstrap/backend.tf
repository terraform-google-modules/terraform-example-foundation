terraform {
  backend "gcs" {
    bucket = "cft-tfstate-0b5e"
    prefix = "terraform/bootstrap/state"
  }
}
