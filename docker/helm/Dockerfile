FROM alpine:3.15.1

RUN apk update && apk upgrade && apk add --no-cache \
  curl \
  unzip \
  python3 \
  py3-pip

RUN curl -s https://get.helm.sh/helm-v3.8.1-linux-amd64.tar.gz -o /tmp/helm-v3.8.1-linux-amd64.tar.gz && \
  tar -zxvf /tmp/helm-v3.8.1-linux-amd64.tar.gz -C /tmp/ && \
  chmod +x /tmp/linux-amd64/helm && mv /tmp/linux-amd64/helm /usr/bin/ && \
  rm -rf /tmp/helm-v3.8.1-linux-amd64.tar.gz

RUN curl -LO https://dl.k8s.io/release/v1.22.0/bin/linux/amd64/kubectl && \
  mv kubectl /usr/bin/ && \
  chmod +x /usr/bin/kubectl

RUN pip install awscli==1.22.82

COPY docker/helm/init.sh /usr/bin/init.sh
WORKDIR /app
ENTRYPOINT [ "/usr/bin/init.sh" ]