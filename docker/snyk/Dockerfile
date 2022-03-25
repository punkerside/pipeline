FROM alpine:3.15.1

RUN apk update && apk upgrade && apk add --no-cache npm && npm install -g snyk

WORKDIR /app
ENTRYPOINT [ "snyk" ]