terraform {
  version = "0.13.5"
}

providers {
  google = {
    version = ["~> 3.30"]
  }
  google-beta = {
    version = ["~> 3.30"]
  }
  external = {
    version = ["~> 1.0"]
  }
  null = {
    version = ["~> 2.0"]
  }
  random = {
    version = ["~> 2.0"]
  }
}
