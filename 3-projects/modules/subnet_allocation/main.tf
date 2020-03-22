locals {
    envs = ["nonprod", "prod"]
    
    vm_subnets = cidrsubnets(var.cidr_vms, 1, 1)

    gke_subnets = { 
        masters = cidrsubnets(var.cidr_gke_masters, 1, 1)
        pods = cidrsubnets(var.cidr_gke_pods, 1, 1)
        services = cidrsubnets(var.cidr_gke_services, 1, 1)
    }

    allocated_vm_subnets = [ for subnet in local.vm_subnets : cidrsubnet(subnet, var.subnet_size, var.project_index) ]
    allocated_master_subnets = [ for subnet in local.gke_subnets.masters : cidrsubnet(subnet, var.subnet_size, var.project_index) ]
    allocated_pod_subnets = [ for subnet in local.gke_subnets.pods : cidrsubnet(subnet, var.subnet_size, var.project_index) ]
    allocated_svc_subnets = [ for subnet in local.gke_subnets.services : cidrsubnet(subnet, var.subnet_size, var.project_index) ]
}

output "network_range" {
    value = { for index, env in local.envs : env => {
        primary_range = local.allocated_vm_subnets[index]
        secondary_ranges = [{ 
            range_name = "${var.application_name}-pod"
            ip_cidr_range = local.allocated_pod_subnets[index]
        },{ 
            range_name = "${var.application_name}-svc"
            ip_cidr_range = local.allocated_svc_subnets[index]
        }]
        gke_master_cidr = local.allocated_master_subnets[index]
    }}
}