FROM golang:alpine AS terraform-bundler

ENV TERRAFORM_VERSION=0.12.26

RUN apk --no-cache add git unzip && \
    go get -d -v github.com/hashicorp/terraform && \
    cd ./src/github.com/hashicorp/terraform && \
    git checkout v${TERRAFORM_VERSION} && \
    go install ./tools/terraform-bundle

COPY containers/terraform/terraform-bundle.hcl .

RUN sed -i "s/{TERRAFORM_VERSION}/${TERRAFORM_VERSION}/" terraform-bundle.hcl && \
    terraform-bundle package -os=linux -arch=amd64 terraform-bundle.hcl && \
    mkdir -p terraform-bundle && \
    unzip -d terraform-bundle terraform_*.zip

####################

FROM ubuntu:18.04

ENV DEBIAN_FRONTEND=noninteractive \
    KUBECTL_VERSION=v1.16.10 \
    TERRAGRUNT_VERSION=v0.23.27 \
    HELM_VERSION=v3.2.4 \
    TF_PLUGIN_CACHE_DIR=/tmp/.terraform/cache

# install system utilities
RUN mkdir -p ${TF_PLUGIN_CACHE_DIR} && \
    apt-get update -qqy && apt-get install -y \
    apt-transport-https bash curl tar openssh-client gnupg python3=3.6.7-1~18.04 python3-distutils \
    sshpass git ca-certificates apt-utils locales wget jq unzip dnsutils make && \
    rm -rf /var/lib/apt/lists/*

# setup locale
RUN echo -e 'LANG="en_US.UTF8"\nLANGUAGE="en_US:en"\n' > /etc/default/locale && \
    locale-gen en_US.UTF-8 && update-locale LANG=en_US.UTF-8

ENV LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 LANGUAGE=en_US:en

# Install kubectl
RUN wget -qO /usr/local/bin/kubectl "https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl" && \
    chmod a+x /usr/local/bin/kubectl

# Install Terraform and provider plugins
COPY --from=terraform-bundler /go/terraform-bundle/terraform /usr/local/bin/
COPY --from=terraform-bundler /go/terraform-bundle/terraform-provider-* ${TF_PLUGIN_CACHE_DIR}/linux_amd64/

# Install Terragrunt
RUN wget -qO /tmp/terragrunt "https://github.com/gruntwork-io/terragrunt/releases/download/${TERRAGRUNT_VERSION}/terragrunt_linux_amd64" && \
    mv /tmp/terragrunt /usr/local/bin/terragrunt && \
    chmod a+x /usr/local/bin/terragrunt

# Install Helm
RUN curl -fsSLO https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz && \
    mkdir -p /tmp/helm && mv helm-${HELM_VERSION}-linux-amd64.tar.gz /tmp/helm && \
    tar xzf /tmp/helm/helm-${HELM_VERSION}-linux-amd64.tar.gz -C /tmp/helm && \
    mv /tmp/helm/linux-amd64/helm /usr/local/bin/helm && rm -rf /tmp/helm

# Install gcloud and Azure CLI
RUN DIST="$(awk -F= '/VERSION_CODENAME/ {print $2}' /etc/os-release)" && \
    curl -sL https://packages.microsoft.com/keys/microsoft.asc | apt-key add - && \
    curl -sL https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - && \
    echo "deb http://packages.cloud.google.com/apt cloud-sdk-${DIST} main" | tee /etc/apt/sources.list.d/google-cloud-sdk.list && \
    echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ ${DIST} main" | tee /etc/apt/sources.list.d/azure-cli.list && \
    apt-get update -qqy && apt-get install google-cloud-sdk azure-cli -y && rm -rf /var/lib/apt/lists/*

# Install AWS CLI
RUN curl -sL https://bootstrap.pypa.io/get-pip.py | python3 && \
    pip3 install awscli

COPY terraform /opt/odahu-flow/terraform
COPY scripts /opt/odahu-flow/scripts
COPY version.info /opt/odahu-flow/version.info

RUN mv /opt/odahu-flow/scripts/tf_runner.sh /usr/bin/tf_runner && \
    chmod a+x /usr/bin/tf_runner

WORKDIR /opt/odahu-flow
