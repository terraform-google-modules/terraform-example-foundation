/**
 * Copyright 2020 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

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

