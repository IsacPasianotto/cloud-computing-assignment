#!/bin/bash 

cd /home/vagrant

# Since during the installation of `k8s` we have set a custom `pod-network-cidr` 
# we need to take this into account when installing the `flannel` network plugin. 
custom_pod_cidr="10.17.0.0/16"
file=calico.yaml

wget https://raw.githubusercontent.com/projectcalico/calico/master/manifests/calico.yaml -O $file


sed -i \
  -e "s|^\(\s*\)#\(\s*- name: CALICO_IPV4POOL_CIDR\)|\1  - name: CALICO_IPV4POOL_CIDR|" \
  -e "s|^\(\s*\)#\(\s*value: \"192.168.0.0/16\"\)|\1  value: \"${custom_pod_cidr}\"|" $file
sed -i -e "s|^\(\s*\)  - name: CALICO_IPV4POOL_CIDR|\1- name: CALICO_IPV4POOL_CIDR|" $file


kubectl apply -f $file

kubectl wait --for=condition=ready pod -l k8s-app=calico-node -n kube-system --timeout=120s
