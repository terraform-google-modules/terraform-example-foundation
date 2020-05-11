terraform {
  backend "gcs" {
    bucket = "cft-tfstate-87c3"
    prefix = "terraform/bootstrap/state"
  }
}
