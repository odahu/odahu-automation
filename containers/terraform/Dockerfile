FROM ubuntu:18.04

ENV DEBIAN_FRONTEND=noninteractive

# install system utilities
RUN apt-get update && apt-get install -y \
    apt-transport-https bash curl tar openssh-client gnupg python3=3.6.7-1~18.04 python3-distutils\
    sshpass git ca-certificates apt-utils locales wget jq unzip rubygems && \
    apt-get clean && apt-get autoclean

# setup locale
RUN locale-gen en_US.UTF-8 && update-locale LANG=en_US.UTF-8
COPY containers/terraform/default_locale /etc/default/locale
RUN chmod 0755 /etc/default/locale
ENV LC_ALL=en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US.UTF-8

# Install kubectl
ENV KUBECTL_VERSION=v1.13.7
RUN wget -qO /usr/local/bin/kubectl "https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl" && \
    chmod a+x /usr/local/bin/kubectl

# Install Terraform
ENV TERRAFORM_VERSION=0.12.6
RUN wget -qO /tmp/terraform.zip "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" && \
    cd /tmp && unzip /tmp/terraform.zip && \
    mv /tmp/terraform /usr/local/bin/terraform && rm -rf /tmp/terraform*

# Install Helm
ENV HELM_VERSION=v2.14.0
RUN curl -fsSLO https://kubernetes-helm.storage.googleapis.com/helm-${HELM_VERSION}-linux-amd64.tar.gz && \
    mkdir -p /tmp/helm && mv helm-${HELM_VERSION}-linux-amd64.tar.gz /tmp/helm && \
    tar xzf /tmp/helm/helm-${HELM_VERSION}-linux-amd64.tar.gz -C /tmp/helm && \
    mv /tmp/helm/linux-amd64/helm /usr/local/bin/helm && rm -rf /tmp/helm

# Install gcloud
RUN CLOUD_SDK_REPO="cloud-sdk-$(grep VERSION_CODENAME /etc/os-release | cut -d '=' -f 2)" && \
    echo "deb http://packages.cloud.google.com/apt $CLOUD_SDK_REPO main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && \
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - && \
    apt-get update -y && apt-get install google-cloud-sdk -y

# Install Hiera
RUN curl https://bootstrap.pypa.io/get-pip.py |python3 && \
    pip3 install pyyaml==5.1.1 && \
    gem install hiera hiera-eyaml

COPY tools/hiera_exporter /opt/legion/tools/hiera_exporter

# Deploy Legion
COPY terraform /opt/legion/terraform
COPY version.info /opt/legion/version.info

WORKDIR /opt/legion
