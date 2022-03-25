FROM alpine:3.15.1

RUN apk update && apk upgrade && apk add --no-cache npm && npm install -g snyk

# ARG SNYK_TOKEN
# ENV SNYK_TOKEN=${SNYK_TOKEN}

WORKDIR /app
# CMD snyk auth ${SNYK_TOKEN} && snyk test
ENTRYPOINT [ "snyk" ]