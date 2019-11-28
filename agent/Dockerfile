FROM mcr.microsoft.com/powershell:6.2.3-centos-7

# Versions
ENV TERRAFORM_VERSION 0.12.16
ENV DOCKERVERSION=19.03.5

RUN rpm --import https://packages.microsoft.com/keys/microsoft.asc && \
    sh -c 'echo -e "[azure-cli]\nname=Azure CLI\nbaseurl=https://packages.microsoft.com/yumrepos/azure-cli\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/azure-cli.repo' && \
    yum install -y azure-cli wget unzip

# Install Terraform
RUN wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    mv terraform /usr/local/bin && \
    rm -f terraform_${TERRAFORM_VERSION}_linux_amd64.zip

# Install DockerCLI
RUN docker_url=https://download.docker.com/linux/static/stable/x86_64 && \
    curl -fsSL $docker_url/docker-${DOCKERVERSION}.tgz | \
    tar zxvf - --strip 1 -C /usr/bin docker/docker