FROM ubuntu:18.04

ENV DEBIAN_FRONTEND=noninteractive

# install system utilities
RUN apt-get update && apt-get install -y \
    python-pip apt-transport-https bash curl tar openssh-client \
    sshpass git ca-certificates python-pip apt-utils locales wget jq rubygems && \
    apt-get clean && apt-get autoclean

# setup locale
RUN locale-gen en_US.UTF-8 && update-locale LANG=en_US.UTF-8
COPY containers/ansible/default_locale /etc/default/locale
RUN chmod 0755 /etc/default/locale
ENV LC_ALL=en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US.UTF-8

# Install ansible with dependencies from pip
RUN pip install ansible==2.7.11 boto==2.49.0 boto3==1.9.169 awscli==1.14.44 cryptography==2.7 apache-libcloud==2.5.0

 # Install ansible dependencies
RUN apt-get install -y \
    python-yaml=3.12-1build2 python-jinja2=2.10-1 \
    python-psycopg2=2.7.4-1 postgresql-client=10+190 python-crypto=2.6.1-8ubuntu2 && \
    apt-get clean && apt-get autoclean

# Configure ansible
RUN mkdir -p /etc/ansible/ && /bin/echo -e "[local]\nlocalhost ansible_connection=local" > /etc/ansible/hosts

# Install kubectl
ENV KUBECTL_VERSION=v1.10.6
RUN wget -qO /usr/local/bin/kubectl "https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl" && \
    chmod a+x /usr/local/bin/kubectl

# Install Kops
ENV KOPS_VERSION=1.10.0
RUN wget -qO /usr/local/bin/kops "https://github.com/kubernetes/kops/releases/download/${KOPS_VERSION}/kops-linux-amd64"  && \
    chmod a+x /usr/local/bin/kops

# Install Helm
ENV HELM_VERSION=v2.14.0
RUN curl -fsSLO https://kubernetes-helm.storage.googleapis.com/helm-${HELM_VERSION}-linux-amd64.tar.gz && \
    mkdir -p /tmp/helm && mv helm-${HELM_VERSION}-linux-amd64.tar.gz /tmp/helm && \
    tar xzf /tmp/helm/helm-${HELM_VERSION}-linux-amd64.tar.gz -C /tmp/helm && \
    mv /tmp/helm/linux-amd64/helm /usr/local/bin/helm && rm -rf /tmp/helm

# Install Hiera
RUN pip install pyyaml==5.1.1 && \
    gem install hiera hiera-eyaml

COPY tools/hiera_exporter /opt/legion/tools/hiera_exporter

# Deploy Legion
COPY ansible /opt/legion/ansible
COPY profiles/profiles_template.yaml /opt/legion/profiles/profiles_template.yaml
COPY profiles/secrets_template.yaml /opt/legion/profiles/secrets_template.yaml
COPY version.info /opt/legion/version.info

WORKDIR /opt/legion
