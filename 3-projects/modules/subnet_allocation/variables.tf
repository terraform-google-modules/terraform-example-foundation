
variable application_name {
    description = "The name of the application on GCP"
    type = string
}

variable project_index {
    description = "The index used for application network allocation"
    type = number
}

variable cidr_vms {
    description = "The network range allocated to apps, e.g. GKE worker nodes or GCE"
    type = string
}

variable cidr_gke_pods {
    description = "The network range allocated to GKE pods"
    type = string
}

variable cidr_gke_services {
    description = "The network range allocated to GKE services"
    type = string
}

variable cidr_gke_masters {
    description = "The network range allocated to private GKE master nodes"
    type = string
}

variable subnet_size {
    description = "The network bit to allocate for each application"
    type = number
}
