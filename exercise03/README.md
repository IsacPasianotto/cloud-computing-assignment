# Solution for the `Cloud-advanced` module second assignment.

This folder contains the provided solution for the second [`Cloud-advanced` module assignment](https://github.com/Foundations-of-HPC/Cloud-advanced-2023/blob/main/Assignments/Exercise.md). 

The assignment file I've considered (it may be changed after this solution is published) is also available in the [assignment.md](./assignment.md) file. 

## 0. Prerequisites

The only prerequisites should be the basic virtualization tools and  `Vagrant` with the respective dependencies.

Since the VM is created using `libvirt`, you'll need also the vagrant plugin `vagrant-libvirt`:

```
vagrant plugin install vagrant-libvirt
```

Even if it's not strictly necessary, in order to retrieve the benchmark results, the `vagrant-scp` plugin is also recommended:

```
vagrant plugin install vagrant-scp
```

## 1. Setup the VM

First of all, you need to create the VM which will be used for this exercise. In the [`k8s-setup`](./k8s-setup/) directory, you will find the `Vagrantfile` and all the needed files to define the network and provision the VM.

```
cd k8s-setup
sudo virsh net-define scripts/ex3-network.xml
sudo virsh net-start ex3-net
vagrant up --no-parallel
```

Once the VMs are up and running, you can ssh into the control plane node (`ex3-00`) and check that both nodes are up and running with:

```
vagrant ssh ex3-00

[vagrant@ex3-00 ~]$ kubectl get nodes -o wide

TODO: add the output of the command


```


## 2. MPI Operator installation:

Following the [official repository documentation](https://github.com/kubeflow/mpi-operator) the installation of the MPI operator (deploy version) can be done with the following command:

```
[vagrant@ex3-00 ~]$ kubectl apply -f https://raw.githubusercontent.com/kubeflow/mpi-operator/master/deploy/v2beta1/mpi-operator.yaml
```


## 3.a. Install flannel:

In the control plane node, you will find a script called [`04_deploy_flannel.sh`](./k8s-setup/scripts/04_deploy_flannel.sh) that will take care of the installation of [`flannel`](https://github.com/flannel-io/flannel). 

```
[vagrant@ex3-00 ~]$ ./04_deploy_flannel.sh
```

Once the pods are up and running (you can check with `k9s`), a reboot of the VMs is necessary to apply the changes to the network configuration. To do so, just run

```
vagrant reload
```

## 3.b. Install calico:

Alternatively, you can install [`calico`](https://github.com/projectcalico/calico) with the [`05_deploy_calico.sh`](./k8s-setup/scripts/05_deploy_calico.sh) script.

note that if you have previously installed flannel, you need to uninstall it with:

```
[vagrant@ex3-00 ~]$ helm uninstall flannel --namespace kube-flannel
```

Before running: 

```
[vagrant@ex3-00 ~]$ ./05_deploy_calico.sh
```

Also in this case, a reboot of the VMs is necessary to apply the changes to the network configuration. To do so, just run `vagrant reload`.

If you want to switch back to flannel, you can do so with the following command:

```
kubectl delete -f calico.yaml
```

where `calico.yaml` is the downloaded and modified file used by the `05_deploy_calico.sh` script.


## 4 Perform the benchmark:

Before running the benchmark, create a dedicated namespace with:

```
kubectl create ns osu
```

Then, to perfor a bencharmk there is provided the [`perform_benchmark.sh`](./k8s-setup/scripts/perform_benchmark.sh) script that will do all the needed steps for you. It is expected to be launched as follow: 

```
[vagrant@ex3-00 ~]$ ./perform_benchmark.sh <yaml-file> <output-file>

where `<yaml-file>` is the name of the yaml file containing the benchmark definition, see the [`yaml-files`](https://github.com/IsacPasianotto/cloud-computing-assignment/tree/main/exercise03/yaml-files) folder for some examples.