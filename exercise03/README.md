# Solution for the `Cloud-advanced` module second assignment.

This folder contains the provided solution for the second [`Cloud-advanced` module assignment](https://github.com/Foundations-of-HPC/Cloud-advanced-2023/blob/main/Assignments/Exercise.md). 

The assignment file I've considered (it may be changed after this solution is published) is also available in the [assignment.md](./assignment.md) file. 



## Notes: 

once you have deployed both of the VM with:

```
sud virsh net-define ./scripts/ex3-netw.xml
vagrant up --no-parallel
```

Now you can ssh into the control plane node  with `vagrant ssh ex3-00`, assign the role to the other node and check that everything is up and in a ready  state with:
```
kubectl label node ex3-01 node-role.kubernetes.io/worker=worker
kubectl get nodes -o wide
```

## Set up the OSU benchmark:

***Requirement***:

Create a container with the OSU benchmark on this page: https://mvapich.cse.ohio-state.edu/benchmarks/. More detailed instructions about compilation can be found here. This container must have a behavior as expected by the operator. Specialized containers must be created to compile and run the code. For example, follow the mpi-operator doc

***end of requirement***





### MPI Operator installation:

Following the [official repository documentation](https://github.com/kubeflow/mpi-operator) the installation of the MPI operator (deploy version) can be done with the following command:

```
kubectl apply -f https://raw.githubusercontent.com/kubeflow/mpi-operator/master/deploy/v2beta1/mpi-operator.yaml
```


## Install flannel:

login into the control plane node and run the following command:

```
vagrant ssh ex3-00

[vagrant@ex3-00 ~]$ ./04_deploy_flannel.sh
```

Then reload the VMs with:

```
vagrant reload
```

The reboot is necessary to apply the changes to the network configuration.


note: check with `k9s` that the pods are up and running before continuing with the next steps.


## CALICO installation:

If you have installed flannel, you can uninstall it with the following command:

```
helm uninstall flannel --namespace kube-flannel
```

Then you can install calico with

```
./05_deploy_calico.sh
```

and then reload the VMs with:

```
vagrant reload
```


if you want to uninstall calico to reinstall flannel, you can just run:
 
```
kubectl delete -f calico.yaml
```

### Container creation:

*Remark*: More implementation of the MPI interface can be found: OpenMPI, MPICH and Intel MPI. Since no specific version is required, I'm going to use the OpenMPI version.


## Perform the benchmark:

```
kubectl create ns osu
```

to perfor a bencharmk we can use the following command:

```
kubectl apply -f ./osu-bench.yaml -n osu 
```

where osu-bench.yaml is replaced to the acutal file name (see the `yaml-files` folder for the file content).

Note that in this way when the benchmark is finished you need to manually delete the pod with:

```
kubectl delete -f ./osu-bench.yaml -n osu 
```

before running the next benchmark. Moreover, the results are only printed to the logs of the `launcher` pod and must be extracted manually with `kubectl logs` before the pod is deleted.

For this reason, I've created a script that will do all of this for you. You can run the `perform_benchmark.sh` script with the following command:

```
./perform_benchmark.sh <number_of_benchmarks>
```