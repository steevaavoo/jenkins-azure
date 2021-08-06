FROM mcr.microsoft.com/powershell:lts-centos-7

# Versions
ENV TERRAFORM_VERSION=0.12.31
ENV DOCKER_VERSION=19.03.5
ENV KUBECTL_VERSION=v1.20.7
ENV HELM_VERSION=3.6.3

# Metadata as defined at http://label-schema.org
LABEL maintainer="Steve Baker" \
    org.label-schema.schema-version="1.0" \
    org.label-schema.name="Jenkins Agent with PowerShell" \
    org.label-schema.license="MIT" \
    org.label-schema.description="A Jenkins Agent with PowerShell, Azure, Terraform, Docker, and Kubernetes CLIs installed." \
    org.label-schema.url="https://github.com/steevaavoo/jenkins-azure/blob/master/README.md" \
    org.label-schema.usage="https://github.com/steevaavoo/jenkins-azure/blob/master/README.md" \
    org.label-schema.vcs-url="https://github.com/steevaavoo/jenkins-azure" \
    org.label-schema.docker.cmd="docker run --rm -it --name jenkins-agent steevaavoo/psjenkinsagent:latest pwsh"

# Install DockerCLI
RUN docker_url=https://download.docker.com/linux/static/stable/x86_64 && \
    curl -fsSL $docker_url/docker-${DOCKER_VERSION}.tgz | \
    tar zxvf - --strip 1 -C /usr/bin docker/docker && \
    rm -f docker-${DOCKER_VERSION}.tgz

# Install Kubectl
# Latest version here: curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl && \
    chmod +x ./kubectl && \
    mv ./kubectl /usr/local/bin/kubectl

# Install yum packages
RUN rpm -Uvh https://packages.microsoft.com/config/centos/7/packages-microsoft-prod.rpm && \
    yum install -y wget unzip jq git which dotnet-sdk-3.1

# Install Terraform
RUN wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    mv terraform /usr/local/bin && \
    rm -f terraform_${TERRAFORM_VERSION}_linux_amd64.zip

# Install Helm
RUN wget https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz && \
    tar -zxvf helm-v${HELM_VERSION}-linux-amd64.tar.gz && \
    mv linux-amd64/helm /usr/local/bin/helm && \
    rm -f helm-v${HELM_VERSION}-linux-amd64.tar.gz

# Install Azure CLI
RUN rpm --import https://packages.microsoft.com/keys/microsoft.asc && \
    sh -c 'echo -e "[azure-cli]\nname=Azure CLI\nbaseurl=https://packages.microsoft.com/yumrepos/azure-cli\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/azure-cli.repo' && \
    yum install -y azure-cli

# Install PowerShell modules
RUN pwsh -Command 'Set-PSRepository -Name "PSGallery" -InstallationPolicy "Trusted"; Install-Module -Name "Pester" -Scope "AllUsers" -Force -Verbose'
