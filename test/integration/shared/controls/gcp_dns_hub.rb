# Copyright 2021 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

dns_hub_project_id = attribute('dns_hub_project_id')

dns_default_region1 = 'us-central1'
dns_default_region2 = 'us-west1'

network_name = 'vpc-c-dns-hub'
dns_fw_zone_name = 'fz-dns-hub'

subnet_name1 = "sb-c-dns-hub-#{dns_default_region1}"
subnet_name2 = "sb-c-dns-hub-#{dns_default_region2}"

region1_router1 = "cr-c-dns-hub-#{dns_default_region1}-cr1"
region1_router2 = "cr-c-dns-hub-#{dns_default_region1}-cr2"
region2_router1 = "cr-c-dns-hub-#{dns_default_region2}-cr3"
region2_router2 = "cr-c-dns-hub-#{dns_default_region2}-cr4"

region1_ip_cidr_range = '172.16.0.0/25'
region2_ip_cidr_range = '172.16.0.128/25'

bgp_asn_dns = 64667
bgp_advertised_ip_ranges = '35.199.192.0/19'

control 'gcp_dns_hub' do
  title 'step 3 dns hub tests'

  describe google_dns_managed_zone(
    project: dns_hub_project_id,
    zone: dns_fw_zone_name
  ) do
    it { should exist }
  end

  describe google_compute_network(
    project: dns_hub_project_id,
    name: network_name
  ) do
    it { should exist }
  end

  describe google_compute_subnetwork(
    project: dns_hub_project_id,
    region: dns_default_region1,
    name: subnet_name1
  ) do
    it { should exist }
    its('ip_cidr_range') { should eq region1_ip_cidr_range }
  end

  describe google_compute_subnetwork(
    project: dns_hub_project_id,
    region: dns_default_region2,
    name: subnet_name2
  ) do
    it { should exist }
    its('ip_cidr_range') { should eq region2_ip_cidr_range }
  end

  describe google_compute_router(
    project: dns_hub_project_id,
    region: dns_default_region1,
    name: region1_router1
  ) do
    it { should exist }
    its('bgp.asn') { should eq bgp_asn_dns }
    its('bgp.advertised_ip_ranges.first.range') { should eq bgp_advertised_ip_ranges }
    its('bgp.advertised_ip_ranges.last.range') { should eq bgp_advertised_ip_ranges }
    its('network') { should match(%r{/#{network_name}$}) }
  end

  describe google_compute_router(
    project: dns_hub_project_id,
    region: dns_default_region1,
    name: region1_router2
  ) do
    it { should exist }
    its('bgp.asn') { should eq bgp_asn_dns }
    its('bgp.advertised_ip_ranges.first.range') { should eq bgp_advertised_ip_ranges }
    its('bgp.advertised_ip_ranges.last.range') { should eq bgp_advertised_ip_ranges }
    its('network') { should match(%r{/#{network_name}$}) }
  end

  describe google_compute_router(
    project: dns_hub_project_id,
    region: dns_default_region2,
    name: region2_router1
  ) do
    it { should exist }
    its('bgp.asn') { should eq bgp_asn_dns }
    its('bgp.advertised_ip_ranges.first.range') { should eq bgp_advertised_ip_ranges }
    its('bgp.advertised_ip_ranges.last.range') { should eq bgp_advertised_ip_ranges }
    its('network') { should match(%r{/#{network_name}$}) }
  end

  describe google_compute_router(
    project: dns_hub_project_id,
    region: dns_default_region2,
    name: region2_router2
  ) do
    it { should exist }
    its('bgp.asn') { should eq bgp_asn_dns }
    its('bgp.advertised_ip_ranges.first.range') { should eq bgp_advertised_ip_ranges }
    its('bgp.advertised_ip_ranges.last.range') { should eq bgp_advertised_ip_ranges }
    its('network') { should match(%r{/#{network_name}$}) }
  end
end
