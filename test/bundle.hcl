terraform {
  version = "0.13.7"
}

providers {
  google = {
    version = ["~> 3.50"]
  }
  google-beta = {
    version = ["~> 3.50"]
  }
  external = {
    version = ["~> 1.0"]
  }
  null = {
    version = ["~> 2.1"]
  }
  random = {
    version = ["~> 2.3"]
  }
}
