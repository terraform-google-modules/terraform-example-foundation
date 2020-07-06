# Copyright 2019 Google LLC
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

FROM gcr.io/cloud-builders/gcloud-slim

ARG TERRAFORM_VERSION=0.12.24
ARG TERRAFORM_VERSION_SHA256SUM=602d2529aafdaa0f605c06adb7c72cfb585d8aa19b3f4d8d189b42589e27bf11

ENV ENV_TERRAFORM_VERSION=$TERRAFORM_VERSION
ENV ENV_TERRAFORM_VERSION_SHA256SUM=$TERRAFORM_VERSION_SHA256SUM

RUN apt-get update && \
   /builder/google-cloud-sdk/bin/gcloud -q components install alpha beta && \
    apt-get -y install curl jq unzip ca-certificates && \
    curl https://releases.hashicorp.com/terraform/${ENV_TERRAFORM_VERSION}/terraform_${ENV_TERRAFORM_VERSION}_linux_amd64.zip \
      > terraform_linux_amd64.zip && \
    echo "${ENV_TERRAFORM_VERSION_SHA256SUM} terraform_linux_amd64.zip" > terraform_SHA256SUMS && \
    sha256sum -c terraform_SHA256SUMS --status && \
    unzip terraform_linux_amd64.zip -d /builder/terraform && \
    rm -f terraform_linux_amd64.zip && \
    apt-get remove --purge -y curl unzip && \
    apt-get --purge -y autoremove && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ENV PATH=/builder/terraform/:$PATH
COPY entrypoint.bash /builder/entrypoint.bash
ENTRYPOINT ["/builder/entrypoint.bash"]