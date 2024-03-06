#!/bin/bash

# need the root privileges

sudo su
mkdir -p /home/vagrant/dockerfiles

################### FILE DEFINITIONS ###################

cat << EOF | tee /home/vagrant/dockerfiles/openmpi-builder.Dockerfile
FROM debian:bullseye as builder

RUN apt update \
    && apt install -y --no-install-recommends \
        g++ \
        libopenmpi-dev \
        make \
    && rm -rf /var/lib/apt/lists/*
EOF

cat << EOF | tee /home/vagrant/dockerfiles/osu-code-provider.Dockerfile
FROM debian:bullseye as osu_code_provider

RUN apt update \
    && apt install -y --no-install-recommends curl ca-certificates \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir /code \
    && curl -o /code/osu-micro-benchmarks-7.3.tar.gz https://mvapich.cse.ohio-state.edu/download/mvapich/osu-micro-benchmarks-7.3.tar.gz --insecure \
    && tar -xvf /code/osu-micro-benchmarks-7.3.tar.gz -C /code \
    && rm -rf /var/lib/apt/lists/*
EOF

cat << EOF | tee /home/vagrant/dockerfiles/openmpi.Dockerfile
FROM mpioperator/base:latest

RUN apt update \
    && apt install -y --no-install-recommends openmpi-bin \
    && rm -rf /var/lib/apt/lists/*
EOF

cat << 'EOF' | tee /home/vagrant/dockerfiles/Dockerfile
FROM localhost/my-builder as builder

RUN mkdir -p /osu

COPY --from=osu-code-provider /code/osu-micro-benchmarks-7.3 /osu

WORKDIR /osu

RUN ./configure CC=mpicc CXX=mpicxx --prefix=/usr/local/osu \
    && make \
    && make install

FROM localhost/my-operator as operator

COPY --from=builder /usr/local/osu /home/mpiuser/osu
EOF

# the default registrvagy is the fedora registry, we need to change it to docker.io
# because the mpioperator/<whatever> images are available only on docker.io

cat << EOF | tee /etc/containers/registries.conf
[registries.search]
registries = ['docker.io']
EOF

################### BUILD IMAGES ###################

cd /home/vagrant/dockerfiles

podman build -f openmpi-builder.Dockerfile -t my-builder
podman build -f osu-code-provider.Dockerfile -t osu-code-provider
podman build -f openmpi.Dockerfile -t my-operator
podman build -t my-osu-bench .

######### Make the images available for the non-root user #########

chown -R vagrant:vagrant /home/vagrant/dockerfiles