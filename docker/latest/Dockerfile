FROM alpine:3.15.1

RUN apk update && apk upgrade && apk add --no-cache \
  nodejs-current \
  curl

COPY app/ /app
RUN adduser --disabled-password --uid 10000 noroot
USER noroot

WORKDIR /app
CMD [ "node", "app.js" ]