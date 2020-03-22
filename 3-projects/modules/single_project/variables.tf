variable project_folder_map {
    description = "Project id mapping from environment to application"
    type = map(string)
}

variable org_id {
    description = "The organization id for the associated services"
    type = string
}

variable billing_account {
    description = "The ID of the billing account to associated this project with"
    type = string
}

variable impersonate_service_account {
    description = "Service account email of the account to impersonate to run Terraform"
    type = string
}

variable project_prefix {
    description = "The name of the GCP project"
    type = string
}

variable cost_centre {
    description = "The cost centre that links to the application"
    type = string
}

variable application_name { 
    description = "The name of application where GCP resources relate"
    type = string
}

variable activate_apis {
    description = "The api to activate for the GCP project"

    type = list(string)
    default = []
}

variable environment {
    description = "The environment the single project belongs to"

    type = string
    default = "prod"
}