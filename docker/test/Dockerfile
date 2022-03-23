ARG IMAGE
FROM ${IMAGE}

RUN apk update && apk add --no-cache npm && npm install -g newman

WORKDIR /app
CMD [ "newman", "run", "tmp/postman_collection.json" ]