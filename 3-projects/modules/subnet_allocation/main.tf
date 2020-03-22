locals {
    envs = ["nonprod", "prod"]
    
    vm_subnets = cidrsubnets(var.cidr_vms, 1, 1)

    gke_subnets = { 
        masters = cidrsubnets(var.cidr_gke_masters, 1, 1)
        pods = cidrsubnets(var.cidr_gke_pods, 1, 1)
        services = cidrsubnets(var.cidr_gke_services, 1, 1)
    }

    allocated_vm_subnet = { for index, subnet in local.vm_subnets : local.envs[index] => cidrsubnet(subnet, var.subnet_size, var.project_index) }
    allocated_master_subnet = { for index, subnet in local.gke_subnets.masters : local.envs[index] => cidrsubnet(subnet, var.subnet_size, var.project_index) }
    allocated_pod_subnet = { for index, subnet in local.gke_subnets.pods : local.envs[index] => cidrsubnet(subnet, var.subnet_size, var.project_index) }
    allocated_svc_subnet = { for index, subnet in local.gke_subnets.services : local.envs[index] => cidrsubnet(subnet, var.subnet_size, var.project_index) }
}

output "subnet_cidr" {
    value = { 
        primary_range = local.allocated_vm_subnet
        secondary_range = [{
            range_name = "${var.application_name}-pod"
            ip_cidr_range = local.allocated_pod_subnet
        },{
            range_name = "${var.application_name}-svc"
            ip_cidr_range = local.allocated_svc_subnet
        }]
        gke_master_cidr = local.allocated_master_subnet
    }
}

# output "gke_master_cidr" {

# }
