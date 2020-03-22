variable terraform_service_account {
    description = "Service account email of the account to impersonate to run Terraform"
    type = string
}

variable organization_id {
    description = "The organization id for the associated services"
    type = string 
}

variable billing_account {
    description = "The ID of the billing account to associated this project with"
    type = string
}

variable default_region {
    description = "Default region for subnet."
    type = string
}

variable cidr_vms {
    description = "The network range allocated to apps, e.g. GKE worker nodes or GCE"
    type = string
    default = "10.32.0.0/11"
}

variable cidr_gke_pods {
    description = "The network range allocated to GKE pods"
    type = string
    default = "10.160.0.0/11"
}

variable cidr_gke_services {
    description = "The network range allocated to GKE services"
    type = string
    default = "10.192.0.0/15"
}

variable cidr_gke_masters {
    description = "The network range allocated to private GKE master nodes"
    type = string
    default = "10.194.0.0/19"
}

variable subnet_size {
    description = "The network bit to allocate for each application"
    type = number
    default = 7 
}