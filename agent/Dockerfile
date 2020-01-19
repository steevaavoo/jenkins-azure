FROM mcr.microsoft.com/powershell:6.2.3-centos-7

# Versions
ENV TERRAFORM_VERSION=0.12.18
ENV DOCKER_VERSION=19.03.5
ENV KUBECTL_VERSION=v1.17.0

# Install Azure CLI
RUN rpm --import https://packages.microsoft.com/keys/microsoft.asc && \
    sh -c 'echo -e "[azure-cli]\nname=Azure CLI\nbaseurl=https://packages.microsoft.com/yumrepos/azure-cli\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/azure-cli.repo' && \
    yum install -y azure-cli wget unzip jq

# Install Terraform
RUN wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    mv terraform /usr/local/bin && \
    rm -f terraform_${TERRAFORM_VERSION}_linux_amd64.zip

# Install DockerCLI
RUN docker_url=https://download.docker.com/linux/static/stable/x86_64 && \
    curl -fsSL $docker_url/docker-${DOCKER_VERSION}.tgz | \
    tar zxvf - --strip 1 -C /usr/bin docker/docker && \
    rm -f docker-${DOCKER_VERSION}.tgz

# Install Kubectl
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl && \
    chmod +x ./kubectl && \
    mv ./kubectl /usr/local/bin/kubectl