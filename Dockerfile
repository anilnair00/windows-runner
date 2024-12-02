FROM plugins/harness_terraform AS custom-root

## Example of an installation using the in-built "microdnf" package manager
RUN microdnf install -y wget
RUN microdnf clean all

## Example of downloading and installing a binary directly
## Binaries need to be suitable for the amd64 architecture
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

# Install dependencies and Azure CLI 
RUN rpm --import https://packages.microsoft.com/keys/microsoft.asc && \
    rpm -Uvh 'https://packages.microsoft.com/config/rhel/8/packages-microsoft-prod.rpm' && \
    microdnf install -y azure-cli && \
    microdnf clean all`
