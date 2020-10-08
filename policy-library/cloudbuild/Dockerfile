# This Dockerfile builds the image used in Cloud Build CI to run 'make test'.
# To push a new image, run 'gcloud builds submit --project=config-validator --tag gcr.io/config-validator/make .'
# from this directory.

FROM debian

RUN apt-get update && apt-get install -y build-essential curl python3 python3-pip
RUN pip3 install pyyaml
RUN curl -L -o \
  /usr/local/bin/opa \
  https://github.com/open-policy-agent/opa/releases/download/__REGO_VERSION__/opa_linux_amd64 \
  && chmod 755 /usr/local/bin/opa

ENTRYPOINT ["make"]
