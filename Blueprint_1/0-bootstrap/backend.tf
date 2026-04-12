terraform {
  backend "gcs" {
    bucket = "food-food-b-seed-tfstate-c551"
    prefix = "terraform/bootstrap/state"
  }
}
