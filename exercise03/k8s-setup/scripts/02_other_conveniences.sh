#!/bin/bash

###### ENABLE kubectl for NON-ROOT USER ######

cd /home/vagrant
mkdir -p .kube
sudo cp /etc/kubernetes/admin.conf .kube/config
sudo chown $(id -u vagrant):$(id -g vagrant) .kube/config

########     INSTALL K9S     ########

cd /tmp
wget https://github.com/derailed/k9s/releases/download/v0.28.2/k9s_Linux_amd64.tar.gz
tar -xvf k9s_Linux_amd64.tar.gz
chmod +x k9s
sudo mv k9s /usr/local/bin

cd ~
cat << EOF | tee -a /home/vagrant/.bashrc
EDITOR=vim
alias k=kubectl
source <(kubectl completion bash)
EOF

######       INSTALL HELM       ######

dnf install -y helm

######      INSTALL OTHER TOOLS      ######

sudo dnf install -y bat htop tmux curl git zsh util-linux-user podman docker
