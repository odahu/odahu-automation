FROM ubuntu:18.04

ENV DEBIAN_FRONTEND=noninteractive \
    KUBECTL_VERSION=v1.13.12 \
    TERRAFORM_VERSION=0.12.19 \
    TERRAGRUNT_VERSION=v0.21.10 \
    HELM_VERSION=v3.1.1

# install system utilities
RUN apt-get update && apt-get install -y \
    apt-transport-https bash curl tar openssh-client gnupg python3=3.6.7-1~18.04 python3-distutils\
    sshpass git ca-certificates apt-utils locales wget jq unzip dnsutils

# setup locale
RUN locale-gen en_US.UTF-8 && update-locale LANG=en_US.UTF-8
COPY containers/terraform/default_locale /etc/default/locale
RUN chmod 0755 /etc/default/locale
ENV LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 LANGUAGE=en_US.UTF-8

# Install kubectl
RUN wget -qO /usr/local/bin/kubectl "https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl" && \
    chmod a+x /usr/local/bin/kubectl

# Install Terraform
RUN wget -qO /tmp/terraform.zip "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" && \
    cd /tmp && unzip /tmp/terraform.zip && \
    mv /tmp/terraform /usr/local/bin/terraform && rm -rf /tmp/terraform*

# Install Terragrunt
RUN wget -qO /tmp/terragrunt "https://github.com/gruntwork-io/terragrunt/releases/download/${TERRAGRUNT_VERSION}/terragrunt_linux_amd64" && \
    mv /tmp/terragrunt /usr/local/bin/terragrunt && \
    chmod a+x /usr/local/bin/terragrunt

# Install Helm
RUN curl -fsSLO https://kubernetes-helm.storage.googleapis.com/helm-${HELM_VERSION}-linux-amd64.tar.gz && \
    mkdir -p /tmp/helm && mv helm-${HELM_VERSION}-linux-amd64.tar.gz /tmp/helm && \
    tar xzf /tmp/helm/helm-${HELM_VERSION}-linux-amd64.tar.gz -C /tmp/helm && \
    mv /tmp/helm/linux-amd64/helm /usr/local/bin/helm && rm -rf /tmp/helm

# Install gcloud
RUN CLOUD_SDK_REPO="cloud-sdk-$(grep VERSION_CODENAME /etc/os-release | cut -d '=' -f 2)" && \
    echo "deb http://packages.cloud.google.com/apt $CLOUD_SDK_REPO main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && \
    curl -sL https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - && \
    apt-get update -y && apt-get install google-cloud-sdk -y

# Install Azure CLI
RUN curl -sL https://packages.microsoft.com/keys/microsoft.asc | apt-key add - && \
    echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $(grep VERSION_CODENAME /etc/os-release | cut -d '=' -f 2) main" | tee /etc/apt/sources.list.d/azure-cli.list && \
    apt-get update -y && apt-get install azure-cli -y && apt-get clean && apt-get autoclean && rm -rf /var/lib/apt/lists/*


# Install AWS CLI
RUN curl -sL https://bootstrap.pypa.io/get-pip.py | python3 && \
    pip3 install awscli

COPY tools/tf_runner.sh /usr/bin/tf_runner
RUN chmod a+x /usr/bin/tf_runner

# Deploy odahuflow
COPY terraform /opt/odahu-flow/terraform
COPY version.info /opt/odahu-flow/version.info

WORKDIR /opt/odahu-flow
