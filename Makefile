PROJECT = falcon
ENV     = lab
SERVICE = api

AWS_REGION      = us-east-1
DOCKER_UID      = $(shell id -u)
DOCKER_GID      = $(shell id -g)
DOCKER_USER     = $(shell whoami)
SONAR_PROJECT   = ${PROJECT}-${ENV}-${SERVICE}
BUILD_TIMESTAMP = $(shell date +"%y%m%d%H%M%S")

base:
	@docker build -t ${PROJECT}-${ENV}-${SERVICE}:tools -f docker/tools/Dockerfile .

file_passwd:
	@echo 'DOCKER_USER:x:DOCKER_UID:DOCKER_GID::/app:/sbin/nologin' > passwd
	@sed -i 's/DOCKER_USER/'"${DOCKER_USER}"'/g' passwd
	@sed -i 's/DOCKER_UID/'"${DOCKER_UID}"'/g' passwd
	@sed -i 's/DOCKER_GID/'"${DOCKER_GID}"'/g' passwd

cluster: file_passwd
	@docker run --rm -u "${DOCKER_UID}":"${DOCKER_GID}" \
	  -v "${PWD}"/passwd:/etc/passwd:ro \
	  -v "${PWD}"/terraform:/app \
	  -v /home/${USER}/.aws/credentials:/tmp/.aws/credentials:ro \
	  -e AWS_CONFIG_FILE=/tmp/.aws/credentials \
	  -e PROJECT=${PROJECT} \
	  -e ENV=${ENV} \
	  -e SERVICE=${SERVICE} \
	  -e AWS_DEFAULT_REGION=${AWS_REGION} \
	  -e AWS_REGION=${AWS_REGION} \
	${PROJECT}-${ENV}-${SERVICE}:tools cluster

sonar: file_passwd
	@[ "${SONAR_ORGANIZATION}" ] && echo "var SONAR_ORGANIZATION is set" || ( echo "var SONAR_ORGANIZATION is not set"; exit 1 )
	@[ "${SONAR_TOKEN}" ] && echo "var SONAR_TOKEN is set" || ( echo "var SONAR_TOKEN is not set"; exit 1 )
	@docker run --rm -u "${DOCKER_UID}":"${DOCKER_GID}" \
	  -e PROJECT=${PROJECT} \
	  -e ENV=${ENV} \
	  -e SERVICE=${SERVICE} \
	  -e SONAR_ORGANIZATION=${SONAR_ORGANIZATION} \
	  -e SONAR_TOKEN=${SONAR_TOKEN} \
	  -v "${PWD}"/passwd:/etc/passwd:ro \
	  -v "${PWD}"/app:/app \
	${PROJECT}-${ENV}-${SERVICE}:tools sonar

build: file_passwd
	@docker run --rm -u "${DOCKER_UID}":"${DOCKER_GID}" -v "${PWD}"/passwd:/etc/passwd:ro -v "${PWD}"/app:/app ${PROJECT}-${ENV}-${SERVICE}:tools build

snyk: file_passwd
	@[ "${SNYK_TOKEN}" ] && echo "var SNYK_TOKEN is set" || ( echo "var SNYK_TOKEN is not set"; exit 1 )
	@docker run --rm -u "${DOCKER_UID}":"${DOCKER_GID}" \
	  -e SNYK_TOKEN=${SNYK_TOKEN} \
	  -v "${PWD}"/passwd:/etc/passwd:ro \
	  -v "${PWD}"/app:/app \
	${PROJECT}-${ENV}-${SERVICE}:tools snyk_cmd

release:
	@docker build -t ${PROJECT}-${ENV}-${SERVICE}:release -f docker/latest/Dockerfile .

postman: file_passwd
	@rm -rf test/tmp/ && mkdir -p test/tmp/
	@cp test/postman_collection.json test/tmp/postman_collection.json
#	iniciando compose
	@export IMAGE=${PROJECT}-${ENV}-${SERVICE}:release && \
	  docker-compose -p "${PROJECT}-${ENV}-${SERVICE}" -f docker-compose.yml up -d
#	capturando ip
	@CONTAINER_IP=$$(docker inspect $$(docker-compose -p ${PROJECT}-${ENV}-${SERVICE} ps -q latest) | jq '.[].NetworkSettings.Networks."'${PROJECT}-${ENV}-${SERVICE}'_default".IPAddress' | cut -d '"' -f 2); \
	sed -i 's|{{CONTAINER_IP}}|'$$CONTAINER_IP'|g' test/tmp/postman_collection.json
#	iniciando pruebas
	@docker run --rm -u "${DOCKER_UID}":"${DOCKER_GID}" --network=${PROJECT}-${ENV}-${SERVICE}_default -v "${PWD}"/passwd:/etc/passwd:ro -v "${PWD}"/test:/app ${PROJECT}-${ENV}-${SERVICE}:tools postman
#	deteniendo compose
	@export IMAGE=${PROJECT}-${ENV}-${SERVICE}:release && \
	  docker-compose -p "${PROJECT}-${ENV}-${SERVICE}" -f docker-compose.yml down

publish:
	@[ "${DOCKER_USERNAME}" ] && echo "var DOCKER_USERNAME is set" || ( echo "var DOCKER_USERNAME is not set"; exit 1 )
	@[ "${DOCKER_PASSWORD}" ] && echo "var DOCKER_PASSWORD is set" || ( echo "var DOCKER_PASSWORD is not set"; exit 1 )
	@docker login -u ${DOCKER_USERNAME} -p ${DOCKER_PASSWORD}
	@docker tag ${PROJECT}-${ENV}-${SERVICE}:release punkerside/${PROJECT}-${ENV}-${SERVICE}:latest
	@docker tag ${PROJECT}-${ENV}-${SERVICE}:release punkerside/${PROJECT}-${ENV}-${SERVICE}:${BUILD_TIMESTAMP}
	@docker push punkerside/${PROJECT}-${ENV}-${SERVICE}:latest
	@docker push punkerside/${PROJECT}-${ENV}-${SERVICE}:${BUILD_TIMESTAMP}

deploy: file_passwd
	docker run --rm -u "${DOCKER_UID}":"${DOCKER_GID}" \
	  -v "${PWD}"/passwd:/etc/passwd:ro \
	  -v "${PWD}"/helm:/app \
	  -v /home/${USER}/.aws/credentials:/tmp/.aws/credentials:ro \
	  -e AWS_CONFIG_FILE=/tmp/.aws/credentials \
	  -e AWS_REGION=${AWS_REGION} \
	  -e PROJECT=${PROJECT} \
	  -e ENV=${ENV} \
	  -e SERVICE=${SERVICE} \
	  -e IMAGE_URI=punkerside/${PROJECT}-${ENV}-${SERVICE}:${BUILD_TIMESTAMP} \
	${PROJECT}-${ENV}-${SERVICE}:tools deploy

destroy:
	@docker run --rm -u "${DOCKER_UID}":"${DOCKER_GID}" -v "${PWD}"/passwd:/etc/passwd:ro -v "${PWD}"/terraform:/app -v /home/${USER}/.aws/credentials:/tmp/.aws/credentials:ro -e AWS_CONFIG_FILE=/tmp/.aws/credentials -e AWS_DEFAULT_REGION=${AWS_REGION} ${PROJECT}-${ENV}-${SERVICE}:terraform destroy -var="project=${PROJECT}" -var="service=${SERVICE}" -var="env=${ENV}" -auto-approve
	@rm -rf app/.config/
	@rm -rf app/.npm/
	@rm -rf app/.scannerwork/
	@rm -rf app/.sonar/
	@rm -rf app/node_modules/
	@rm -rf app/package-lock.json
	@rm -rf test/tmp/
	@rm -rf passwd
	@rm -rf terraform/.terraform/
	@rm -rf terraform/.terraform.d/
	@rm -rf terraform/.terraform.lock.hcl
	@rm -rf terraform/terraform.tfstate
	@rm -rf terraform/terraform.tfstate.backup