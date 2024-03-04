#!/bin/bash

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
dnf install -y iproute-tc wget vim bash-completion bat

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

########     CONFIGURE kubectl    ########

export ipmaster=192.168.132.60
scp -o StrictHostKeyChecking=no root@$ipmaster:/home/vagrant/admin.conf /home/vagrant/admin.conf


mkdir -p $HOME/.kube
sudo cp -i /home/vagrant/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
alias k=kubectl


cd /home/vagrant
mkdir -p .kube
sudo cp /home/vagrant/admin.conf .kube/config
sudo chown $(id -u vagrant):$(id -g vagrant) .kube/config


########     JOIN THE CLUSTER   ########

# The join command is provided by the master node
export ipmaster=192.168.132.60
scp -o StrictHostKeyChecking=no root@$ipmaster:/root/kubejoin_command.sh /root
/root/kubejoin_command.sh



############# INSTALL CNI PLUGINS #############

sudo mkdir -p /opt/cni/bin
sudo curl -O -L https://github.com/containernetworking/plugins/releases/download/v1.2.0/cni-plugins-linux-amd64-v1.2.0.tgz
sudo tar -C /opt/cni/bin -xzf cni-plugins-linux-amd64-v1.2.0.tgz


########     INSTALL K9S     ########

cd /tmp
wget https://github.com/derailed/k9s/releases/download/v0.28.2/k9s_Linux_amd64.tar.gz
tar -xvf k9s_Linux_amd64.tar.gz
chmod +x k9s
sudo mv k9s /usr/local/bin

cat << EOF | tee -a /home/vagrant/.bashrc
EDITOR=vim
alias k=kubectl
source <(kubectl completion bash)
EOF


######       INSTALL HELM       ######

sudo dnf install -y helm


######      INSTALL OTHER TOOLS      ######


sudo dnf install -y bat htop tmux curl git zsh util-linux-user podman
