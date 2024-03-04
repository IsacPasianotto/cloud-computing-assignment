# Source: 
# https://github.com/kubeflow/mpi-operator/blob/master/build/base/openmpi-builder.Dockerfile

FROM debian:bullseye as openmpi_builder

RUN apt update \
    && apt install -y --no-install-recommends \
        g++ \
        libopenmpi-dev \
        build-essential \
    && rm -rf /var/lib/apt/lists/*