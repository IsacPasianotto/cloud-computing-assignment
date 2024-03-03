# Exercise 2


## Prerequisites

Only the basic tools to run a VM are required. 
In particular, you need to have installed:

- `Vagrant`
- `libvirt`


with they respective dependencies.
Since the VM is created using `libvirt`, you'll need also the vagrant plugin `vagrant-libvirt`:

```
vagrant plugin install vagrant-libvirt
```

## Setup the VM

First of all, you need to create the VM which will be used for this exercise. 

```
cd k8s-setup 
sudo virsh net-define scripts/ex2-network.xml
sudo virsh net-start ex2-net
vagrant up
```

## Nextcloud deployment

Once the VM is up and running, you will need to ssh into it, then you will file the [`nextcloud-helm&yaml](./nextcloud-helm&yaml/) directory, which contains the files needed to deploy the nextcloud instance.

```bash
vagrant ssh ex2-00
cd nextcloud-helm&yaml
```

Now in order to have the nextcloud instance up and running, you need to follow the steps below:

### 1. Install the load balancer

```bash
cd metallb

kubectl apply -f metallb-baremetal.yaml

kubectl wait --for=condition=available --timeout=600s deployment/controller -n metallb-system

kubectl apply -f cm.yaml
kubectl apply -f ipaddresspool.yaml
kubectl apply -f l2advertisement.yaml
```



### 2. Install the `nginx` ingress controller


To deploy the [nginx ingress controller](https://kubernetes.github.io/ingress-nginx/deploy/), run the following command:

```bash
cd ../ingress-nginx

kubectl apply -f ingress-nginx-controller.yaml

kubectl wait --for=condition=available --timeout=600s deployment/ingress-nginx-controller -n ingress-nginx
```


### 3. Create the namespace `nextcloud` and define the needed `pv` and `pvc`

```bash

cd ../volumes

kubectl apply -f local-path.yaml

kubectl create namespace nextcloud 

kubectl apply -f nextcloud-pv.yaml -n nextcloud
kubectl apply -f nextcloud-pvc.yaml -n nextcloud
kubectl apply -f postgres-pv.yaml -n nextcloud
kubectl apply -f postgres-pvc.yaml -n nextcloud
```



### 4. Certificates

in the `certificates` directory, you will find the files needed to create the certificates for the `nextcloud` instance.

Create the certificates using the following command (important, the `Common Name` must be the same as the `hostname` of the VM, in this case `nextcloud.kube.home`)

```bash
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout ex2-00.key -out ex2-00.crt
```
Then create the `secret` using the following command:

```bash
kubectl create secret tls nextcloud-tls --cert=ex2-00.crt --key=ex2-00.key
kubectl create secret tls nextcloud-tls --cert=ex2-00.crt --key=ex2-00.key -n nextcloud 
```


### 5. Create the `secret`s needed

Modify the values of the following secrets as you prefer:


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



### 6. Install `nextcloud`

```bash
cd .. # go back to the exercise directory

helm repo add nextcloud https://nextcloud.github.io/helm/
helm repo update

helm install my-nextcloud-instance nextcloud/nextcloud -f values.yaml -n nextcloud

kubectl wait --for=condition=available --timeout=600s deployment/my-nextcloud-instance-nextcloud -n nextcloud
```



## NOTES:

- Why postresql and not mariadb? see [this bug](https://github.com/nextcloud/helm/issues/506)



- If you change the `hostname` of the vagrant machine, you need to update the `*-pv.yaml` files with the new hostname in the `volumes` directory


- If you use a different `namespace`, remeber to update the `metrics.ServiceMonitor.namespace` and `metrics.ServiceMonitor.namespaceSelector` values in the `values.yaml` file. 