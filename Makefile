PROJECT = sandbox
ENV     = lab
SERVICE = api

DOCKER_UID  = $(shell id -u)
DOCKER_GID  = $(shell id -g)
DOCKER_USER = $(shell whoami)

SONAR_PROJECT      = ${PROJECT}-${ENV}-${SERVICE}
SONAR_ORGANIZATION = punkerside-github
SONAR_TOKEN        = 64b6f************

base:
	@docker build -t ${PROJECT}-${ENV}-${SERVICE}:base -f docker/base/Dockerfile .
	@docker build --build-arg IMAGE=${PROJECT}-${ENV}-${SERVICE}:base -t ${PROJECT}-${ENV}-${SERVICE}:build -f docker/build/Dockerfile .
	@docker build --build-arg IMAGE=${PROJECT}-${ENV}-${SERVICE}:base -t ${PROJECT}-${ENV}-${SERVICE}:postman -f docker/postman/Dockerfile .
	@docker build -t ${PROJECT}-${ENV}-${SERVICE}:sonar -f docker/sonar/Dockerfile .

file_passwd:
	@echo 'DOCKER_USER:x:DOCKER_UID:DOCKER_GID::/app:/sbin/nologin' > passwd
	@sed -i 's/DOCKER_USER/'"${DOCKER_USER}"'/g' passwd
	@sed -i 's/DOCKER_UID/'"${DOCKER_UID}"'/g' passwd
	@sed -i 's/DOCKER_GID/'"${DOCKER_GID}"'/g' passwd

build: file_passwd
	docker run --rm -u "${DOCKER_UID}":"${DOCKER_GID}" -v "${PWD}"/passwd:/etc/passwd:ro -v "${PWD}"/app:/app ${PROJECT}-${ENV}-${SERVICE}:build

release:
	@docker build --build-arg IMAGE=${PROJECT}-${ENV}-${SERVICE}:base -t ${PROJECT}-${ENV}-${SERVICE}:release -f docker/latest/Dockerfile .

postman:
	@rm -rf test/tmp/ && mkdir -p test/tmp/
	@cp test/postman_collection.json test/tmp/postman_collection.json
#	iniciando compose
	@export IMAGE=${PROJECT}-${ENV}-${SERVICE}:release && \
	  docker-compose -p "${PROJECT}-${ENV}-${SERVICE}" -f docker-compose.yml up -d
#	capturando ip
	@CONTAINER_IP=$$(docker inspect $$(docker-compose -p ${PROJECT}-${ENV}-${SERVICE} ps -q latest) | jq '.[].NetworkSettings.Networks."'${PROJECT}-${ENV}-${SERVICE}'_default".IPAddress' | cut -d '"' -f 2); \
	sed -i 's|{{CONTAINER_IP}}|'$$CONTAINER_IP'|g' test/tmp/postman_collection.json
#	iniciando pruebas
	@docker run --rm -u "${DOCKER_UID}":"${DOCKER_GID}" --network=${PROJECT}-${ENV}-${SERVICE}_default -v "${PWD}"/passwd:/etc/passwd:ro -v "${PWD}"/test:/app ${PROJECT}-${ENV}-${SERVICE}:postman
#	deteniendo compose
	@export IMAGE=${PROJECT}-${ENV}-${SERVICE}:release && \
	  docker-compose -p "${PROJECT}-${ENV}-${SERVICE}" -f docker-compose.yml down

sonar:
	docker run --rm -u "${DOCKER_UID}":"${DOCKER_GID}" --env SONAR_PROJECT=${SONAR_PROJECT} --env SONAR_ORGANIZATION=${SONAR_ORGANIZATION} --env SONAR_TOKEN=${SONAR_TOKEN} -v "${PWD}"/passwd:/etc/passwd:ro -v "${PWD}"/app:/app ${PROJECT}-${ENV}-${SERVICE}:sonar