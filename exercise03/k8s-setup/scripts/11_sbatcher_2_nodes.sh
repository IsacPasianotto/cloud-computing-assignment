#!/bin/bash
#SBATCH --no-requeue
#SBATCH --job-name="osu-test"
#SBATCH --partition=debug
#SBATCH --nodes=2
#SBATCH --ntasks=2
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=2G
#SBATCH --time=02:00:00
#SBATCH --get-user-env

# Standard preamble
echo "---------------------------------------------"
echo "SLURM job ID:        $SLURM_JOB_ID"
echo "SLURM job node list: $SLURM_JOB_NODELIST"
echo "hostname:            $(hostname)"
echo "DATE:                $(date)"
echo "---------------------------------------------"

export OMPI_ALLOW_RUN_AS_ROOT=1
export OMPI_ALLOW_RUN_AS_ROOT_CONFIRM=1

module load mpi/openmpi-x86_64

export situation="pre-CNI"
# export situation="flannel-CNI"
# export situation="calico-CNI"
export filename="latency-2-nodes-baremetal-$situation.txt"

for i in {1..20}
do
        mpirun -np 2 /home/vagrant/shared/my-osu/libexec/osu-micro-benchmarks/mpi/pt2pt/osu_latency >> /home/vagrant/shared/results/$filename
done
