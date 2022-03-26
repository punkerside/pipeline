FROM alpine:3.15.1

RUN apk update && apk upgrade && apk add --no-cache \
  nodejs-current \
  npm \
  curl \
  unzip \
  aws-cli \
  jq \
  gettext \
  busybox-extras \
  openjdk11-jdk \
  openjdk11-jre \
  python3 \
  py3-pip

RUN curl -s https://releases.hashicorp.com/terraform/1.1.7/terraform_1.1.7_linux_amd64.zip -o /tmp/terraform_1.1.7_linux_amd64.zip && \
  unzip /tmp/terraform_1.1.7_linux_amd64.zip -d /tmp/ && \
  chmod +x /tmp/terraform && mv /tmp/terraform /usr/bin/ && \
  rm -rf /tmp/terraform_1.1.7_linux_amd64.zip

RUN curl -o sonar-scanner-cli-4.2.0.1873-linux.zip https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-4.2.0.1873-linux.zip && \
  unzip sonar-scanner-cli-4.2.0.1873-linux.zip && mv sonar-scanner-4.2.0.1873-linux/ sonar-scanner/ && rm -rf sonar-scanner-cli-4.2.0.1873-linux.zip && \
  sed -i 's/use_embedded_jre=true/use_embedded_jre=false/g' /sonar-scanner/bin/sonar-scanner

RUN curl -s https://get.helm.sh/helm-v3.8.1-linux-amd64.tar.gz -o /tmp/helm-v3.8.1-linux-amd64.tar.gz && \
  tar -zxvf /tmp/helm-v3.8.1-linux-amd64.tar.gz -C /tmp/ && \
  chmod +x /tmp/linux-amd64/helm && mv /tmp/linux-amd64/helm /usr/bin/ && \
  rm -rf /tmp/helm-v3.8.1-linux-amd64.tar.gz

RUN curl -LO https://dl.k8s.io/release/v1.22.0/bin/linux/amd64/kubectl && \
  mv kubectl /usr/bin/ && \
  chmod +x /usr/bin/kubectl

ENV SONAR_PROJECT=${SONAR_PROJECT}
ENV SONAR_ORGANIZATION=${SONAR_ORGANIZATION}
ENV SONAR_TOKEN=${SONAR_TOKEN}

RUN npm install -g snyk newman

COPY docker/tools/init.sh /usr/bin/init.sh
WORKDIR /app
ENTRYPOINT ["/usr/bin/init.sh"]