#!/bin/sh

cluster () {
    # creando
    terraform init
    terraform plan -var="project=${PROJECT}" -var="service=${SERVICE}" -var="env=${ENV}"
    terraform apply -var="project=${PROJECT}" -var="service=${SERVICE}" -var="env=${ENV}" -auto-approve
    # configurando
    export KUBECONFIG=/tmp/${PROJECT}-${ENV}
    aws eks update-kubeconfig --name ${PROJECT}-${ENV} --region ${AWS_REGION}
    kubectl patch deployment coredns -n kube-system --type json -p='[{"op": "remove", "path": "/spec/template/metadata/annotations/eks.amazonaws.com~1compute-type"}]'
    kubectl rollout restart -n kube-system deployment coredns
}

sonar () {
    /sonar-scanner/bin/sonar-scanner \
      -Dsonar.projectKey=${PROJECT}-${ENV}-${SERVICE} \
      -Dsonar.organization=${SONAR_ORGANIZATION} \
      -Dsonar.sources=. \
      -Dsonar.host.url=https://sonarcloud.io \
      -Dsonar.exclusions=.scannerwork/ \
      -Dsonar.exclusions=node_modules/ \
      -Dsonar.exclusions=.npm/
}

build () {
    npm install
}

snyk_cmd () {
    snyk auth ${SNYK_TOKEN}
    snyk test
}

postman () {
    newman run tmp/postman_collection.json
}

deploy () {
    export KUBECONFIG=/tmp/${PROJECT}-${ENV}
    aws eks update-kubeconfig --name ${PROJECT}-${ENV} --region ${AWS_REGION}
    helm upgrade --install ${PROJECT}-${ENV}-${SERVICE} --set spec.containers.image=${IMAGE_URI} ./
}

"$@"