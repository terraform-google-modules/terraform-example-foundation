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

ARG GCLOUD_VERSION=slim
FROM google/cloud-sdk:${GCLOUD_VERSION}

# Use ARG so that values can be overriden by user/cloudbuild
ARG TERRAFORM_VERSION=1.0.0
ARG TERRAFORM_VERSION_SHA256SUM=8be33cc3be8089019d95eb8f546f35d41926e7c1e5deff15792e969dde573eb5

ENV ENV_TERRAFORM_VERSION=$TERRAFORM_VERSION
ENV ENV_TERRAFORM_VERSION_SHA256SUM=$TERRAFORM_VERSION_SHA256SUM

RUN apt-get update && \
    apt-get -y install curl jq unzip git ca-certificates google-cloud-sdk-terraform-tools && \
    curl https://releases.hashicorp.com/terraform/${ENV_TERRAFORM_VERSION}/terraform_${ENV_TERRAFORM_VERSION}_linux_amd64.zip \
      > terraform_linux_amd64.zip && \
    echo "${ENV_TERRAFORM_VERSION_SHA256SUM} terraform_linux_amd64.zip" > terraform_SHA256SUMS && \
    sha256sum -c terraform_SHA256SUMS --status && \
    mkdir -p /builder && \
    unzip terraform_linux_amd64.zip -d /builder/terraform && \
    rm -f terraform_linux_amd64.zip terraform_SHA256SUMS && \
    apt-get --purge -y autoremove && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ENV PATH=/builder/terraform/:$PATH
COPY entrypoint.bash /builder/entrypoint.bash
RUN chmod +x /builder/entrypoint.bash
ENTRYPOINT ["/builder/entrypoint.bash"]
