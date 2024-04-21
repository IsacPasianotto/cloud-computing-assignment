#!/bin/bash

mkdir -p /home/vagrant/shared/my-osu
mkdir -p /home/vagrant/shared/code
mkdir -p /home/vagrant/shared/results


cd /home/vagrant/shared/code
wget wget http://mvapich.cse.ohio-state.edu/download/mvapich/osu-micro-benchmarks-7.3.tar.gz
tar -xf osu-micro-benchmarks-7.3.tar.gz
cd osu-micro-benchmarks-7.3
./configure CC=mpicc CXX=mpicxx --prefix=/home/vagrant/shared/my-osu
make
make install
