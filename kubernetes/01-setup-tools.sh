#!/usr/bin/env bash

# Install Contour as Ingress Controller
kubectl create namespace projectcontour
kubectl apply -f https://projectcontour.io/quickstart/contour.yaml

# Configure External DNS with Google DNS
kubectl create secret generic gcp-key -n projectcontour --from-file=gcp.key.json
helm upgrade -i external-dns bitnami/external-dns -n projectcontour --values external-dns-values.yaml

# Install Cert Manager for automatic TLS certificate management
kubectl create namespace cert-manager
kubectl create secret generic gcp-key -n cert-manager --from-file=gcp.key.json
helm install cert-manager jetstack/cert-manager -n cert-manager --version v1.0.3 --set installCRDs=true
kubectl apply -f cert-issuers.yaml -n cert-manager

# Install Gitlab
kubectl create namespace gitlab
helm upgrade -i gitlab gitlab/gitlab -n gitlab --timeout 600s --values gitlab-values.yaml
kubectl get secret gitlab-gitlab-initial-root-password -n gitlab -ojsonpath='{.data.password}' | base64 --decode ; echo

# Install Harbor
kubectl create namespace harbor
helm upgrade -i harbor bitnami/harbor -n harbor --values harbor-values.yaml

# Install ArgoCD
kubectl create namespace argocd
helm upgrade -i argocd argo/argo-cd -n argocd --values argocd-values.yaml
kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-server -o name | cut -d'/' -f 2; echo

# Install Artifactory
kubectl create namespace artifactory
helm upgrade -i artifactory -n artifactory center/jfrog/artifactory-oss --values artifactory-values.yaml

# Install Kpack
kubectl create namespace kpack
kubectl apply -f kpack-release-0.1.2.yaml
