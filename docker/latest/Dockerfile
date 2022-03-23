ARG IMAGE
FROM ${IMAGE}

COPY app/ /app
RUN adduser --disabled-password --uid 10000 noroot
USER noroot

CMD [ "node", "app.js" ]