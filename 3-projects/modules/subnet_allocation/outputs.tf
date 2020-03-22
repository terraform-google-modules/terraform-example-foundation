output "network_range" {
    description = "The map for app subnet allocation for all environments"
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