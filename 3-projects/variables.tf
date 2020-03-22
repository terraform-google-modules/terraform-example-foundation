variable terraform_service_account {
    type = string
}

variable organization_id {
    type = string 
}

variable billing_account {
    type = string
}

variable default_region {
    type = string
}

variable cidr_vms {
    type = string
    default = "10.32.0.0/11"
}

variable cidr_gke_pods {
    type = string
    default = "10.160.0.0/11"
}

variable cidr_gke_services {
    type = string
    default = "10.192.0.0/15"
}

variable cidr_gke_masters {
    type = string
    default = "10.194.0.0/19"
}

variable subnet_size {
    type = number
    default = 7 
}