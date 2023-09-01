terraform {
  required_providers {
    gitlab = {
      source  = "gitlabhq/gitlab"
      version = "~> 16.2.0"
    }
  }
}

variable "gitlab_token" {
  type = string
}

provider "gitlab" {
  token = var.gitlab_token
}

provider "null" {}

resource "null_resource" "gcloud_auth_list" {
  provisioner "local-exec" {
    command = "gcloud auth list"
  }
}