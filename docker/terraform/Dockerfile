FROM alpine:3.15.1

# variables de entrada
RUN apk update && apk add --no-cache \
  curl \
  unzip \
  aws-cli \
  jq \
  gettext

# instalando terraform
RUN curl -s https://releases.hashicorp.com/terraform/1.1.7/terraform_1.1.7_linux_amd64.zip -o /tmp/terraform_1.1.7_linux_amd64.zip && \
  unzip /tmp/terraform_1.1.7_linux_amd64.zip -d /tmp/ && \
  chmod +x /tmp/terraform && mv /tmp/terraform /usr/bin/ && \
  rm -rf /tmp/terraform_1.1.7_linux_amd64.zip

# configurando entorno
WORKDIR /app
ENTRYPOINT ["/usr/bin/terraform"]