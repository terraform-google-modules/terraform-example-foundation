variable project_folder_map {
    type = map(string)
}

variable org_id {
    type = string
}

variable billing_account {
    type = string
}

variable impersonate_service_account {
    type = string
}

variable project_prefix {
    type = string
}

variable cost_centre {
    type = string
}

variable application_name { 
    type = string
}

variable activate_apis {
    type = list(string)
    default = []
}

variable subnet_allocation {

}

variable enable_networking {
    type = bool
    default = true
}
