#!/bin/sh

export KUBECONFIG=/tmp/${EKS_CLUSTER}
aws eks update-kubeconfig --name ${EKS_CLUSTER} --region ${AWS_REGION}

# kubectl patch deployment coredns -n kube-system --type json -p='[{"op": "remove", "path": "/spec/template/metadata/annotations/eks.amazonaws.com~1compute-type"}]'
# kubectl rollout restart -n kube-system deployment coredns

# helm upgrade --install ${EKS_SERVICE} --set spec.containers.image=${IMAGE_URI} ./

kubectl get pods --all-namespaces
