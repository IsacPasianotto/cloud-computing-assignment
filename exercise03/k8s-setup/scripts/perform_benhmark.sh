#!/bin/bash

if [ -z "$(kubectl get namespace osu)" ]; then
    echo "The namespace osu does not exist. Please create it first."
    exit 1
fi

if [ $# -lt 2 ]; then
    echo "At least 2 arguments are required. Please provide the yaml file to perform the benchmark and file to store the results."
    exit 1
fi

if [ ! -f $1 ]; then
    echo "The file $1 does not exist."
    exit 1
fi

export yaml_file=$1
export results_file=$2

kubectl apply -f $yaml_file --namespace osu

export pod_name=$(kubectl get pods -n osu | grep launcher | awk '{print $1}')

while [ "$(kubectl get pod $pod_name -n osu -o jsonpath='{.status.phase}')" != "Succeeded" ]; do
    echo "Waiting for the benchmark to complete..."
    sleep 5
done

kubectl logs $pod_name -n osu >> $results_file
echo "Result have been appended to $results_file"

kubectl delete -f $yaml_file --namespace osu
