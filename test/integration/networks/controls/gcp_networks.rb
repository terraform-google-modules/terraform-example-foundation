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

enable_hub_and_spoke = attribute('enable_hub_and_spoke')

restricted_dev_project_id = attribute('dev_restricted_host_project_id')
restricted_nonprod_project_id = attribute('nonprod_restricted_host_project_id')
restricted_prod_project_id = attribute('prod_restricted_host_project_id')

base_dev_project_id = attribute('dev_base_host_project_id')
base_nonprod_project_id = attribute('nonprod_base_host_project_id')
base_prod_project_id = attribute('prod_base_host_project_id')

environment_codes = %w(d n p)

projects_id = {
  'd' => { 'base' => base_dev_project_id, 'restricted' => restricted_dev_project_id },
  'n' => { 'base' => base_nonprod_project_id, 'restricted' => restricted_nonprod_project_id },
  'p' => { 'base' => base_prod_project_id, 'restricted' => restricted_prod_project_id },
}

cidr_ranges = {
  'd' => { 'base' => ['10.0.64.0/21', '10.1.64.0/21'], 'restricted' => ['10.8.64.0/21', '10.9.64.0/21'] },
  'n' => { 'base' => ['10.0.128.0/21', '10.1.128.0/21'], 'restricted' => ['10.8.128.0/21', '10.9.128.0/21'] },
  'p' => { 'base' => ['10.0.192.0/21', '10.1.192.0/21'], 'restricted' => ['10.8.192.0/21', '10.9.192.0/21'] },
}

googleapis_cidr = { 'base' => '199.36.153.8/30', 'restricted' => '199.36.153.4/30' }

types = %w(base restricted)

default_region1 = 'us-west1'
default_region2 = 'us-central1'

bgp_asn_subnet = 64_514

control 'gcp_networks' do
  title 'step 3 networks tests'

  environment_codes.each do |environment_code|
    types.each do |type|
      vpc_name = enable_hub_and_spoke ? "#{environment_code}-shared-#{type}-spoke" : "#{environment_code}-shared-#{type}"
      network_name = "vpc-#{vpc_name}"

      global_address = "ga-#{vpc_name}-vpc-peering-internal"

      dns_zone_googleapis = "dz-#{environment_code}-shared-#{type}-apis"
      dns_zone_gcr = "dz-#{environment_code}-shared-#{type}-gcr"
      dns_zone_pkg_dev = "dz-#{environment_code}-shared-#{type}-pkg-dev"
      dns_zone_peering_zone = "dz-#{environment_code}-shared-#{type}-to-dns-hub"

      subnet_name1 = "sb-#{environment_code}-shared-#{type}-#{default_region1}"
      subnet_name2 = "sb-#{environment_code}-shared-#{type}-#{default_region2}"

      region1_router1 = "cr-#{vpc_name}-#{default_region1}"
      region1_router2 = "cr-#{vpc_name}-#{default_region1}"
      region2_router1 = "cr-#{vpc_name}-#{default_region2}"
      region2_router2 = "cr-#{vpc_name}-#{default_region2}"

      if type == 'base'
        region1_router1 = "#{region1_router1}-cr1"
        region1_router2 = "#{region1_router2}-cr2"
        region2_router1 = "#{region2_router1}-cr3"
        region2_router2 = "#{region2_router2}-cr4"
      else
        region1_router1 = "#{region1_router1}-cr5"
        region1_router2 = "#{region1_router2}-cr6"
        region2_router1 = "#{region2_router1}-cr7"
        region2_router2 = "#{region2_router2}-cr8"
      end

      fw_deny_all_egress = "fw-#{environment_code}-shared-#{type}-65535-e-d-all-all-all"
      fw_allow_api_egress = "fw-#{environment_code}-shared-#{type}-65534-e-a-allow-google-apis-all-tcp-443"

      describe google_dns_managed_zone(
        project: projects_id[environment_code][type],
        zone: dns_zone_googleapis
      ) do
        it { should exist }
      end

      describe google_dns_managed_zone(
        project: projects_id[environment_code][type],
        zone: dns_zone_gcr
      ) do
        it { should exist }
      end

      describe google_dns_managed_zone(
        project: projects_id[environment_code][type],
        zone: dns_zone_pkg_dev
      ) do
        it { should exist }
      end

      describe google_dns_managed_zone(
        project: projects_id[environment_code][type],
        zone: dns_zone_peering_zone
      ) do
        it { should exist }
      end

      describe google_compute_network(
        project: projects_id[environment_code][type],
        name: network_name
      ) do
        it { should exist }
      end

      describe google_compute_global_address(
        project: projects_id[environment_code][type],
        name: global_address
      ) do
        it { should exist }
      end

      describe google_compute_subnetwork(
        project: projects_id[environment_code][type],
        region: default_region1,
        name: subnet_name1
      ) do
        it { should exist }
        its('ip_cidr_range') { should eq cidr_ranges[environment_code][type][0] }
      end

      describe google_compute_subnetwork(
        project: projects_id[environment_code][type],
        region: default_region2,
        name: subnet_name2
      ) do
        it { should exist }
        its('ip_cidr_range') { should eq cidr_ranges[environment_code][type][1] }
      end

      describe google_compute_firewall(
        project: projects_id[environment_code][type],
        name: fw_deny_all_egress
      ) do
        its('log_config_enabled?') { should be true }
        its('direction') { should cmp 'EGRESS' }
        its('destination_ranges') { should eq ['0.0.0.0/0'] }
        it 'denies all protocols' do
          expect(subject.denied).to contain_exactly(
            an_object_having_attributes(ip_protocol: 'all', ports: nil)
          )
        end
      end

      describe google_compute_firewall(
        project: projects_id[environment_code][type],
        name: fw_allow_api_egress
      ) do
        its('direction') { should cmp 'EGRESS' }
        its('log_config_enabled?') { should be true }
        its('destination_ranges') { should eq [googleapis_cidr[type]] }
        it { should allow_target_tags ['allow-google-apis'] }
        it 'allows TCP' do
          expect(subject.allowed).to contain_exactly(
            an_object_having_attributes(ip_protocol: 'tcp', ports: ['443'])
          )
        end
      end

      unless enable_hub_and_spoke
        describe google_compute_router(
          project: projects_id[environment_code][type],
          region: default_region1,
          name: region1_router1
        ) do
          it { should exist }
          its('bgp.asn') { should eq bgp_asn_subnet }
          its('bgp.advertised_ip_ranges.first.range') { should eq googleapis_cidr[type] }
          its('bgp.advertised_ip_ranges.last.range') { should eq googleapis_cidr[type] }
          its('network') { should match(%r{/#{network_name}$}) }
        end

        describe google_compute_router(
          project: projects_id[environment_code][type],
          region: default_region1,
          name: region1_router2
        ) do
          it { should exist }
          its('bgp.asn') { should eq bgp_asn_subnet }
          its('bgp.advertised_ip_ranges.first.range') { should eq googleapis_cidr[type] }
          its('bgp.advertised_ip_ranges.last.range') { should eq googleapis_cidr[type] }
          its('network') { should match(%r{/#{network_name}$}) }
        end

        describe google_compute_router(
          project: projects_id[environment_code][type],
          region: default_region2,
          name: region2_router1
        ) do
          it { should exist }
          its('bgp.asn') { should eq bgp_asn_subnet }
          its('bgp.advertised_ip_ranges.first.range') { should eq googleapis_cidr[type] }
          its('bgp.advertised_ip_ranges.last.range') { should eq googleapis_cidr[type] }
          its('network') { should match(%r{/#{network_name}$}) }
        end

        describe google_compute_router(
          project: projects_id[environment_code][type],
          region: default_region2,
          name: region2_router2
        ) do
          it { should exist }
          its('bgp.asn') { should eq bgp_asn_subnet }
          its('bgp.advertised_ip_ranges.first.range') { should eq googleapis_cidr[type] }
          its('bgp.advertised_ip_ranges.last.range') { should eq googleapis_cidr[type] }
          its('network') { should match(%r{/#{network_name}$}) }
        end
      end
    end
  end
end
