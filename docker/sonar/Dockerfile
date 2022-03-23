FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y curl unzip openjdk-11-jdk openjdk-11-jre && curl -sL https://deb.nodesource.com/setup_14.x | bash - && apt -y install nodejs

RUN curl -o sonar-scanner-cli-4.2.0.1873-linux.zip https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-4.2.0.1873-linux.zip && \
  unzip sonar-scanner-cli-4.2.0.1873-linux.zip && mv sonar-scanner-4.2.0.1873-linux/ sonar-scanner/ && rm -rf sonar-scanner-cli-4.2.0.1873-linux.zip

ARG SONAR_PROJECT
ARG SONAR_ORGANIZATION
ARG SONAR_TOKEN

ENV SONAR_PROJECT=${SONAR_PROJECT}
ENV SONAR_ORGANIZATION=${SONAR_ORGANIZATION}
ENV SONAR_TOKEN=${SONAR_TOKEN}

WORKDIR /app
CMD /sonar-scanner/bin/sonar-scanner -Dsonar.projectKey=${SONAR_PROJECT} -Dsonar.organization=${SONAR_ORGANIZATION} -Dsonar.sources=. -Dsonar.host.url=https://sonarcloud.io