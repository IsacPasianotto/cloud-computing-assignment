#!/bin/bash

# need the root privileges

# sudo su
# mkdir -p /home/vagrant/dockerfiles

################### FILE DEFINITIONS ###################

# cat << EOF | tee /home/vagrant/dockerfiles/openmpi_builder.Dockerfile
# FROM debian:bullseye as openmpi_builder

# RUN apt update \
#     && apt install -y --no-install-recommends \
#         g++ \
#         libopenmpi-dev \
#         build-essential \
#     && rm -rf /var/lib/apt/lists/*
# EOF

# cat << EOF | tee /home/vagrant/dockerfiles/osu_code_provider.Dockerfile
# FROM debian:bullseye as osu_code_provider

# RUN apt update \
#     && apt install -y --no-install-recommends curl ca-certificates \
#     && rm -rf /var/lib/apt/lists/* \
#     && mkdir /code \
#     && curl -o /code/osu-micro-benchmarks-7.3.tar.gz https://mvapich.cse.ohio-state.edu/download/mvapich/osu-micro-benchmarks-7.3.tar.gz --insecure \
#     && tar -xvf /code/osu-micro-benchmarks-7.3.tar.gz -C /code \
#     && rm -rf /var/lib/apt/lists/*
# EOF

# cat << EOF | tee /home/vagrant/dockerfiles/osu_compiled.Dockerfile
# FROM openmpi-builder as osu-binary-provider

# COPY --from=osu-code-provider /code/osu-micro-benchmarks-7.3 /code/osu-micro-benchmarks-7.3

# WORKDIR /code/osu-micro-benchmarks-7.3

# RUN mkdir /code/osu-micro-benchmarks-7.3/build  \
#     && ./configure CC=mpicc CXX=mpicxx --prefix=/code/osu-micro-benchmarks-7.3/build \
#     && make \
#     && make install \
#     && mkdir -p /osu \
#     && cp -r /code/osu-micro-benchmarks-7.3/build /osu
# EOF

# cat << EOF | tee /home/vagrant/dockerfiles/osu.Dockerfile
# FROM mpioperator/base:latest

# RUN apt update \
#     && apt install -y --no-install-recommends \
#         dnsutils \
#         mpich \
#         bc \ 
#     && rm -rf /var/lib/apt/lists/*

# COPY --from=osu-compiled /osu /home/mpiuser/osu
# COPY entrypoint.sh /entrypoint.sh
# ENTRYPOINT ["/entrypoint.sh"]
# EOF

# cat << 'EOF' | tee /home/vagrant/dockerfiles/entrypoint.sh
# #!/bin/bash

# set_intel_vars=/opt/intel/oneapi/setvars.sh
# if [ -f "$set_intel_vars" ]; then
#   source "$set_intel_vars"
# fi

# function resolve_host() {
#   host="$1"
#   check="nslookup $host"
#   max_retry=10
#   counter=0
#   backoff=0.1
#   until $check > /dev/null
#   do
#     if [ $counter -eq $max_retry ]; then
#       echo "Couldn't resolve $host"
#       return
#     fi
#     sleep $backoff
#     echo "Couldn't resolve $host... Retrying"
#     ((counter++))
#     backoff=$(echo "$backoff + $backoff" | bc)
#   done
#   echo "Resolved $host"
# }

# if [ "$K_MPI_JOB_ROLE" == "launcher" ]; then
#   resolve_host "$HOSTNAME"
#   cut -d ':' -f 1 /etc/mpi/hostfile | while read -r host
#   do
#     resolve_host "$host"
#   done
# fi

# exec "$@"
# EOF


# chmod +x /home/vagrant/dockerfiles/entrypoint.sh

# ######### SETTING docker.io AS THE DEFAULT REGISTRY #########

# # the default registrvagy is the fedora registry, we need to change it to docker.io
# # because the mpioperator/base:latest is available only on docker.io

# cat << EOF | tee /etc/containers/registries.conf
# [registries.search]
# registries = ['docker.io']
# EOF



# ######### BUILD IMAGES #########

# cd /home/vagrant/dockerfiles

# podman build -f openmpi_builder.Dockerfile -t openmpi-builder .
# podman build -f osu_code_provider.Dockerfile -t osu-code-provider .
# podman build -f osu_compiled.Dockerfile -t osu-compiled .
# podman build -f osu.Dockerfile -t my-osu-image .



# ######### Make the images available for the non-root user #########

# chown -R vagrant:vagrant /home/vagrant/dockerfiles


#####################################################################
#####################################################################
#####################################################################


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


