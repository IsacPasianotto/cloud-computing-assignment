# Exercise 2: mpi service in Kubernetes (Advanced)

### Introduction

The exercise addresses the task of porting simple HPC workflows into Kubernetes by testing your proficiency not only in Kubernetes but also with Docker and HPC workflows.

You are supposed to run the [OSU benchmark](https://mvapich.cse.ohio-state.edu/benchmarks/) inside two containers distributed in different nodes in the Kubernetes cluster.

### Requirements

- the cluster must run `k8s`; two nodes are necessary,
- the nodes must talk via either `flannel` or `calico`,
- the [mpi operator](https://github.com/kubeflow/mpi-operator) must be installed,
- Create a container with the OSU benchmark on this page: https://mvapich.cse.ohio-state.edu/benchmarks/. More detailed instructions about compilation can be found [here](https://mvapich.cse.ohio-state.edu/static/media/mvapich/README-OMB.txt). This container must have a behavior as expected by the operator. Specialized containers must be created to compile and run the code. For example, follow the [mpi-operator doc](https://github.com/kubeflow/mpi-operator/tree/master/build/base) 
- use the code to estimate the latency between the two nodes (by placing one worker per node) and at least one between collective operations. Compare these results with those when both pods are on the same node.

### Submission detail

Documentation:

- Not required

Code:

- publish all the value files used in your helm charts, the developed manifests and Dockerfiles, and any code eventually developed/modified necessary to deploy your cloud-based file storage system in a vanilla clean cluster.
- Include a README file with instructions on how to deploy and use your system.

Presentation:

- Extend the presentation for exercises one and two, summarizing any **interesting** challenges you faced and the results you obtained (no more than five extra slides)
- Be ready to answer questions about the topics discussed during the Cloud Course Lectures
  
### Evaluation Criteria:

- Design Clarity: Is the system design well-documented and clear?
- Functionality: Does the system meet the specified requirements?
