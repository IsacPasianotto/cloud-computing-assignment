#!/bin/bash

# the Container Network Interface (CNI) plugin to use
export cni="flannel"
#export cni="calico"

export file1="latency-1-node.yaml"
export file2="latency-2-nodes.yaml"
export file3="collective-allgather-1node.yaml"
export file4="collective-allgather-2nodes.yaml"

export data1="latency-1-node-${cni}.log"
export data2="latency-2-nodes-${cni}.log"
export data3="collective-allgather-1node-${cni}.log"
export data4="collective-allgather-2nodes-${cni}.log"

export niter=20

# perform the actual benchmark

echo "==========================="
echo "== latency-1-node.yaml =="
echo "==========================="

for ((i = 1; i <= niter; i++))
do
    echo "................."
    echo "  Iteration $i"
    echo "................."
    ./perform_benchmark.sh "$file1" "$data1"
done

echo "==========================="
echo "== latency-2-nodes.yaml =="
echo "==========================="

for ((i = 1; i <= niter; i++))
do
    echo "................."
    echo "  Iteration $i"
    echo "................."
    ./perform_benchmark.sh "$file2" "$data2"
done

echo "======================================"
echo "== collective-allgather-1node.yaml =="
echo "======================================"

for ((i = 1; i <= niter; i++))
do
    echo "................."
    echo "  Iteration $i"
    echo "................."
    ./perform_benchmark.sh "$file3" "$data3"
done

echo "======================================"
echo "== collective-allgather-2nodes.yaml =="
echo "======================================"

for ((i = 1; i <= niter; i++))
do
    echo "................."
    echo "  Iteration $i"
    echo "................."
    ./perform_benchmark.sh "$file4" "$data4"
done
