# Assignments for the course "Cloud computing" exam

This repository contains the assignments for the exam of the course "Cloud computing" that I attended at the University of Trieste (AY 2022-23). 

**Author**: [Isac Pasianotto](mailto:ISAC.PASIANOTTO@studenti.units.it)

**Report**: [PASIANOTTO_report.pdf](./PASIANOTTO_report.pdf)

**Presentation**: [Presentation](./Presentation.pdf)

**Course**: [module base](https://github.com/Foundations-of-HPC/Cloud-Basic-2023), [module advanced](https://github.com/Foundations-of-HPC/Cloud-advanced-2023)


## Repository structure

The assignment is composed of two exercises, each of them in its own folder: 

- [Assignment 1](./Assignment1): The depolyment of a container based file storage system, done implementing [nextcloud](https://nextcloud.com/) with [`docker-compose`](https://docs.docker.com/compose/). 
- [Assignment 2](./Assignment2): Replicate the deployment of the previous assignment, but in a [`kubernetes`](https://kubernetes.io/) environment. This is done in a `k8s` single node cluster, deployed using [`vagrant`](https://www.vagrantup.com/).
- [Assignment 3](./Assignment3): Peroformed the [osu benchmark](https://mvapich.cse.ohio-state.edu/benchmarks/) on a `k8s` 2-nodes cluster. Also in this case, the cluster is deployed using `vagrant`.

More information are available in the `README.md` files in each folder and in the report of the assignments uploaded in this repository. 
