# Exercise 2


## Prerequisites

Only the basic tools to run a VM are required.
In particular, you need to have installed:

- `Vagrant`
- `virsh`

with they respective dependencies.

Since the VM is created using `libvirt`, you'll need also the vagrand plugin `vagrant-libvirt`:

```
vagrant plugin install vagrant-libvirt
```

## Setup

First of all, you need to create the VM which will be used for this exercise. 

```
cd k8s-setup 
sudo virsh net-define scripts/ex2-network.xml
sudo virsh net-start ex2-net
vagrant up
```

