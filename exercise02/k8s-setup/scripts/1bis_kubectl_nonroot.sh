#!/bin/bash


# This part is not strictly necessary, it's just the sequence of 
# commands the vagrant user should execute if you want to use 
# kubectl as a non-root user.
#
# Note. This script must be execute as non-root!
#
# For the purpose of the exercise, using root is fine.
#


# If not, start from the $HOME directory
cd /home/vagrant
mkdir -p .kube
sudo cp /etc/kubernetes/admin.conf .kube/config
sudo chown $(id -u vagrant):$(id -g vagrant) .kube/config
