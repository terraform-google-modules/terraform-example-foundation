terraform {
  version = "0.12.29"
}

providers {
  google = ["~> 3.30"]
  google-beta = ["~> 3.30"]
  external = ["~> 1.0"]
  null = ["~> 2.0"]
  random = ["~> 2.0"]
}
