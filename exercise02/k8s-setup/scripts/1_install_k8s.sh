#!/bin/bash

# Attribution: 
#     Script builded following the tutorial from the course this exercise is part of.
#     The original tutorial can be found at: 
#     https://github.com/Foundations-of-HPC/Cloud-advanced-2023/blob/main/live-demos/kubernetes/0-kube-installation/notes.org

# Login as root, as some of the commands require root access
sudo su 


########   PRELIMINARY STEPS   ########



# Load the modules for the container runtime
modprobe overlay
modprobe br_netfilter

# Make the changes permanent
cat <<EOF | tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

# Set the kernel parameters
cat <<EOF |  tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward = 1
EOF

# Load kernel parameters at runtime
sysctl --system

# disable zram
touch /etc/systemd/zram-generator.conf
swapoff -a

setenforce 0
sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config


# Install the required packages
dnf install -y iproute-tc wget vim bash-completion bat \
    podman  

########     K8S INSTALLATION     ########

# Set the repository 
cat << EOF | tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.28/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.28/rpm/repodata/repomd.xml.key
exclude=kubelet kubeadm kubectl cri-tools kubernetes-cni
EOF


dnf makecache
dnf install -y crio kubelet kubeadm kubectl --disableexcludes=kubernetes

# Enable and start the services

sed -i 's/10.85.0.0\/16/10.17.0.0\/16/' /etc/cni/net.d/100-crio-bridge.conflist
systemctl enable --now crio
systemctl enable --now kubelet


kubeadm init --pod-network-cidr=10.17.0.0/16
# --services-cidr=10.96.0.0/12 /default
# --control-plane-endpoint 192.168.132.80 /needed for HA

# temporary log-out 
su vagrant

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
alias k=kubectl

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



########     REMOVE THE TAIN     ########



sudo kubectl taint nodes --all  node-role.kubernetes.io/control-plane-
