#!/bin/bash
# Copyright 2020 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#install jq
#apt-get update
#apt-get -y install jq
curl -L "https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh" | sudo bash
#sudo apt-get -y install gitlab-runner

sudo sed -i '/[runners.docker]/a image = "docker:dind"' /etc/gitlab-runner/conf.toml
sudo sed -i '/image = "docker:dind"/a privileged = true' /etc/gitlab-runner/conf.toml
sudo sed -i '/privileged = true/a tls_verify = false' /etc/gitlab-runner/conf.toml

# [[runners]]
#   name = "RUNNER-XXX"
#   url = "https://gitlab.com/"
#   id = 27149207
#   token = "glrt-XXX"
#   token_obtained_at = 2023-08-22T13:53:29Z
#   token_expires_at = 0001-01-01T00:00:00Z
#   executor = "docker"
#   [runners.cache]
#     MaxUploadedArchiveSize = 0
#   [runners.docker]
#     tls_verify = false
#     image = "docker:dind"
#     privileged = true 
#     disable_entrypoint_overwrite = false
#     oom_kill_disable = false
#     disable_cache = false
#     volumes = ["/cache"]
#     shm_size = 0
