# Steps to deploy: 


1. first of all let's create a builder image (which is a base debian images with the chosen compiler and mpi implementation installed) 

```
sudo podman build -f openmpi-builder.Dockerfile -t my-builder 
```

2. create the pod which download the source code we want to use

```
sudo podman build -f osu-code-provider.Dockerfile -t osu-code-provider
```

3. Create the container with the mpi binaries:

```
sudo podman build -f openmpi.Dockerfile -t my-operator
```

4. Create the final pod with the mpi binaries

```
sudo podman build -t my-osu-bench .
```


Remark: since this images are built locally and not pulled from a registry, the images are not tagged with a registry name. This means that the images are not available to other nodes in the cluster. For this reason I've built the images node by node.