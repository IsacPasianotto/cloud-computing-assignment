#!/bin/bash

export cni=flannel-kube
# export cni=calico-kube

for i in {1..20}
do
  /home/vagrant/06_perform_benchmark.sh latency-2-nodes.yaml /home/vagrant/shared/results/latency-2-nodes-$cni.txt
done


for i in {1..20}
do
  /home/vagrant/06_perform_benchmark.sh latency-1-node.yaml /home/vagrant/shared/results/latency-1-node-$cni.txt
done
