# Solution for the `Cloud-advanced` module first assignment.

This folder contains the provided solution for the first [`Cloud-advanced` module assignment](https://github.com/Foundations-of-HPC/Cloud-advanced-2023/blob/main/Assignments/Exercise.md). 

The assignment file I've considered (it may be changed after this solution is published) is also available in the [assignment.md](./assignment.md) file. 


### 0. Prerequisites

The only prerequisites should be the basic virtualization tools and  `Vagrant` with the respective dependencies.

Since the VM is created using `libvirt`, you'll need also the vagrant plugin `vagrant-libvirt`:

```
vagrant plugin install vagrant-libvirt
```

### 1. Setup the VM

First of all, you need to create the VM which will be used for this exercise. In the [`k8s-setup`](./k8s-setup/) directory, you will find the `Vagrantfile` and all the needed files to define the network and provision the VM.

```
cd k8s-setup 
sudo virsh net-define scripts/ex2-network.xml
sudo virsh net-start ex2-net
vagrant up
```

## Nextcloud deployment

Once the VM is up and running, you will need to ssh into it, then you will file the [`nextcloud-helm&yaml](https://github.com/IsacPasianotto/cloud-computing-assignment/tree/main/exercise02/nextcloud-helm%26yaml) directory, which contains the files needed to deploy the nextcloud instance.

```bash
vagrant ssh ex2-00
cd nextcloud-helm\&yaml
```

Now in order to have the nextcloud instance up and running, you need to follow the steps below:

### 2. Install the load balancer

To install the [MetalLB](https://metallb.universe.tf/) load balancer, run the following commands:

```bash
cd metallb

kubectl apply -f metallb-baremetal.yaml

kubectl wait --for=condition=available --timeout=600s deployment/controller -n metallb-system

kubectl apply -f cm.yaml
kubectl apply -f ipaddresspool.yaml
kubectl apply -f l2advertisement.yaml
```

### 3. Create the namespace `nextcloud` and define the needed `pv` and `pvc`

Persist the volumes are used to store the data in case of a pod failure.

```bash
cd ../volumes

kubectl apply -f local-path.yaml

kubectl create namespace nextcloud 

kubectl apply -f nextcloud-pv.yaml -n nextcloud
kubectl apply -f nextcloud-pvc.yaml -n nextcloud
kubectl apply -f postgres-pv.yaml -n nextcloud
kubectl apply -f postgres-pvc.yaml -n nextcloud
```

### 4. Create the `secret`s needed

Secret are used to store sensitive information, such as passwords and tokens. The used helm chart expects the following secrets to be created:

```bash
kubectl create secret generic -n nextcloud nextcloud-credentials \
  --from-literal=username=admin \
  --from-literal=password=changeme \
  --from-literal=nextcloud-token=vVjGFYXE14 

kubectl create secret generic -n nextcloud postgres-credentials \
  --from-literal=db-name=nextcloud \
  --from-literal=db-user=nextcloud \
  --from-literal=db-password=changeme \
  --from-literal=db-root-password=changeme 

kubectl create secret generic -n nextcloud redis-credentials \
  --from-literal=redis-password=changeme
```

### 5. Install `nextcloud`

Finally, you can install the nextcloud instance using the [`helm`](https://helm.sh/) package manager and the official [nextcloud helm chart](https://github.com/nextcloud/helm/tree/main/charts/nextcloud)

```bash
cd .. # go back to the exercise directory

helm repo add nextcloud https://nextcloud.github.io/helm/
helm repo update

helm install my-nextcloud-instance nextcloud/nextcloud -f values.yaml -n nextcloud
```

## Access the nextcloud instance

You can access the nextcloud instance searching for the `external-ip` of the service `my-nextcloud-instance-nextcloud`:

You can access the nextcloud instance through the [`service`](https://kubernetes.io/docs/concepts/services-networking/service/) the helm chart creates.
It will have the name equals to the `release-name` we used in the installation (i.e. `my-nextcloud-instance` in this case). 
On the vagrant machine ensure that the service exists, and then you can use the `kubectl port-forward` command to access the nextcloud instance:

```
[vagrant@ex2-00 ~]$ kubectl get svc -n nextcloud
NAME                                   TYPE           CLUSTER-IP       EXTERNAL-IP       PORT(S)          AGE
my-nextcloud-instance                  LoadBalancer   10.100.237.26    192.168.121.201   8080:32019/TCP   6m55s
...                                    ...            ...              ...               ...              ...

[vagrant@ex2-00 ~]$ tmux new-session -d -s nextcloud-portforward "kubectl port-forward service/my-nextcloud-instance 8080:8080 --address 0.0.0.0 -n nextcloud"
```

On you host machine run:

```
export guest_ip=$(vagrant ssh-config $(vagrant global-status | awk '/ex2-00/ {print $1}') | awk '/HostName/ {print $2}')
export guest_port=8080
export host_port=8080

ssh vagrant@$guest_ip -L $host_port:$guest_ip:$guest_port -i ./ssh/id_rsa
```
the password for the `vagrant` user is `vagrant`. 

Finally, you can access through the browser at `http://localhost:8080`


***Some notes:***

- If you change the `hostname` of the vagrant machine, you need to update the `*-pv.yaml` files with the new hostname in the `volumes` directory
- If you use a different `namespace`, remember to update the `metrics.ServiceMonitor.namespace` and `metrics.ServiceMonitor.namespaceSelector` values in the `values.yaml` file. 