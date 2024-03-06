#!/bin/bash

# Since during the installation of `k8s` we have set a custom `pod-network-cidr` 
# we need to take this into account when installing the `flannel` network plugin. 
export custom_pod_network_cidr=10.17.0.0/16

kubectl create namespace kube-flannel
kubectl label --overwrite ns kube-flannel pod-security.kubernetes.io/enforce=privileged

helm repo add flannel https://flannel-io.github.io/flannel/
helm install flannel --set podCidr="$custom_pod_network_cidr" --namespace kube-flannel flannel/flannel