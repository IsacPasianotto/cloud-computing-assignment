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


## Install flannel:

login into the control plane node and run the following command:

```
vagrant ssh ex3-00

[vagrant@ex3-00 ~]$ ./03_deploy_flannel.sh
```

note: check with `k9s` that the pods are up and running before continuing with the next steps.

## Set up the OSU benchmark:

***Requirement***:

Create a container with the OSU benchmark on this page: https://mvapich.cse.ohio-state.edu/benchmarks/. More detailed instructions about compilation can be found here. This container must have a behavior as expected by the operator. Specialized containers must be created to compile and run the code. For example, follow the mpi-operator doc

***end of requirement***

### MPI Operator installation:

Following the [official repository documentation](https://github.com/kubeflow/mpi-operator) the installation of the MPI operator (Release version 0.4.0) can be done with the following command:

```
kubectl apply -f https://raw.githubusercontent.com/kubeflow/mpi-operator/v0.4.0/deploy/v2beta1/mpi-operator.yaml
 ```


### Container creation:

*Remark*: More implementation of the MPI interface can be found: OpenMPI, MPICH and Intel MPI. Since no specific version is required, I'm going to use the OpenMPI version.



#### 1. build the *builder* container: 

This container is going to be used to compile the OSU benchmark, it's a simple debian container with the `gcc` compiler and `openmpi` installed.

```
podman build -f openmpi_builder.Dockerfile -t openmpi-builder .
```

#### 2. build the *osu benchmark* container:


the `openmpi-builder` container is going to be used to compile the OSU benchmark, all the compilation details can be founded [there](https://mvapich.cse.ohio-state.edu/static/media/mvapich/README-OMB.txt). 

The `osu_code_provider.Dockerfile` will take care to deliver to the compiler container the source code and the compilation instructions.

Create the image with the following command:

```
podman build -f osu_code_provider.Dockerfile -t osu-code-provider .
```


Now we can define the `osu-benchmarks` container, which is responsible for compiling the code given by the `osu-code-provider` with the software stack provided by the `openmpi-builder` container.

execute the following command to create the container:

```
podman build -f osu_benchmarks.Dockerfile -t osu-benchmarks .
```


#### 3. Build the final container:

We need a container which has a behavior as expected by the MPI operator. To do that we can rely on the [`mpi-operator`](https://hub.docker.com/u/mpioperator) official image


```
podman build -f osu.Dockerfile -t osu .
```


## Perform the benchmark:


***TODO***