# Base image
FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04

# Avoid interactive tzdata/etc
ENV DEBIAN_FRONTEND=noninteractive \
    TERRAFORM_VERSION=1.9.5 \
    AWSCLI_VERSION=2.17.32 \
    TFLINT_VERSION=0.53.0 \
    TERRAFORM_DOCS_VERSION=0.19.0 \
    TERRAGRUNT_VERSION=0.67.6 \
    INFRACOST_VERSION=0.10.42

# Install packages & tools
RUN apt-get update && apt-get upgrade -y && \
        apt-get install -y --no-install-recommends \
            curl ca-certificates unzip less jq git gnupg lsb-release bash-completion python3 python3-pip software-properties-common make pre-commit && \
        rm -rf /var/lib/apt/lists/*

# Install Terraform
RUN curl -fsSL https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip -o /tmp/terraform.zip && \
    unzip /tmp/terraform.zip -d /usr/local/bin && \
    rm /tmp/terraform.zip && \
    terraform -install-autocomplete

# Install AWS CLI v2 (pinned)
RUN curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64-${AWSCLI_VERSION}.zip" -o /tmp/awscliv2.zip && \
    unzip /tmp/awscliv2.zip -d /tmp && \
    /tmp/aws/install && \
    rm -rf /tmp/aws /tmp/awscliv2.zip

# Install tflint
RUN curl -fsSL https://github.com/terraform-linters/tflint/releases/download/v${TFLINT_VERSION}/tflint_linux_amd64.zip -o /tmp/tflint.zip && \
    unzip /tmp/tflint.zip -d /usr/local/bin && rm /tmp/tflint.zip

# Install terraform-docs
RUN curl -fsSL https://github.com/terraform-docs/terraform-docs/releases/download/v${TERRAFORM_DOCS_VERSION}/terraform-docs-v${TERRAFORM_DOCS_VERSION}-linux-amd64.tar.gz -o /tmp/terraform-docs.tgz && \
    tar -xzf /tmp/terraform-docs.tgz -C /usr/local/bin terraform-docs && rm /tmp/terraform-docs.tgz

# Install terragrunt
RUN curl -fsSL https://github.com/gruntwork-io/terragrunt/releases/download/v${TERRAGRUNT_VERSION}/terragrunt_linux_amd64 -o /usr/local/bin/terragrunt && \
    chmod +x /usr/local/bin/terragrunt

# Install infracost
RUN curl -fsSL https://github.com/infracost/infracost/releases/download/v${INFRACOST_VERSION}/infracost-linux-amd64.tar.gz -o /tmp/infracost.tgz && \
    tar -xzf /tmp/infracost.tgz -C /tmp && mv /tmp/infracost-linux-amd64/infracost /usr/local/bin/infracost && \
    rm -rf /tmp/infracost.tgz /tmp/infracost-linux-amd64

# Enable bash completion for terraform & aws
RUN echo 'complete -C /usr/local/bin/terraform terraform' >> /etc/bash_completion.d/terraform && \
    aws --version

# Create a non-root user (codespace) if base image didn't already
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN if ! id -u "$USERNAME" >/dev/null 2>&1; then \
      groupadd --gid $USER_GID $USERNAME && \
      useradd --uid $USER_UID --gid $USER_GID -m $USERNAME && \
      echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/$USERNAME; \
    fi

USER $USERNAME
WORKDIR /workspaces

# Terraform & AWS history / convenience
RUN echo 'export TF_CLI_ARGS_plan="-parallelism=100"' >> ~/.bashrc && \
    echo 'export TF_CLI_ARGS_apply="-parallelism=100"' >> ~/.bashrc && \
    echo 'export TF_CLI_ARGS_destroy="-parallelism=100"' >> ~/.bashrc && \
    echo 'alias tf=terraform' >> ~/.bashrc && \
    echo 'alias tfi="terraform init"' >> ~/.bashrc && \
    echo 'alias tfp="terraform plan"' >> ~/.bashrc && \
    echo 'alias tfa="terraform apply"' >> ~/.bashrc && \
    echo 'alias tfdestroy="terraform destroy"' >> ~/.bashrc && \
    echo 'alias tfs="terraform show"' >> ~/.bashrc && \
    echo 'alias tfo="terraform output"' >> ~/.bashrc && \
    echo 'alias tfls="terraform state list"' >> ~/.bashrc && \
    echo 'alias tg=terragrunt' >> ~/.bashrc && \
    echo 'alias awsenv="aws sts get-caller-identity"' >> ~/.bashrc && \
    echo 'alias tfd="terraform-docs markdown table ."' >> ~/.bashrc && \
    echo 'alias tfl="tflint --enable-rule=terraform_unused_declarations"' >> ~/.bashrc && \
    echo 'alias icost="infracost breakdown --path ."' >> ~/.bashrc

# Pre-create .aws directory for mounted credentials/SSO cache
RUN mkdir -p ~/.aws && chmod 700 ~/.aws

# Health check script placeholder
COPY healthcheck.sh /usr/local/bin/devcontainer-healthcheck
RUN chmod +x /usr/local/bin/devcontainer-healthcheck

HEALTHCHECK CMD devcontainer-healthcheck || exit 1

# Final message
CMD ["bash"]
