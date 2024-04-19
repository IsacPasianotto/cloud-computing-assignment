#!/bin/bash

# Login as root, as some of the commands require root access
sudo su 


### Populate /etc/hosts file with the IP addresses and hostnames of the nodes in the cluster

echo "" >> /etc/hosts
echo "192.168.132.60 ex3-00 ex3-00" >> /etc/hosts
echo "192.168.132.61 ex3-01 ex3-01" >> /etc/hosts
echo "192.168.132.62 ex3-02 ex3-02" >> /etc/hosts

### Set the NFS server on the client nodes

dnf install -y nfs-utils libnfsidmap sssd-nfs-idmap

mkdir -p /home/vagrant/ 
mkdir -p /home/vagrant/shared

mount -t nfs ex3-00:/export/home/vagrant/shared /home/vagrant/shared
echo 'ex3-00:/export/home/vagrant/shared /home/vagrant/shared nfs defaults 0 0' | sudo tee -a /etc/fstab

systemctl enable --now nfs-client.target

### Slurm needs munge to be installed and running on all nodes


export MUNGEUSER=1001
groupadd -g $MUNGEUSER munge
useradd  -m -c "MUNGE Uid 'N' Gid Emporium" -d /var/lib/munge -u $MUNGEUSER -g munge -s /sbin/nologin munge
mkdir  -p /etc/munge /var/log/munge /var/run/munge
chown  munge:munge /var/log/munge /var/run/munge

export SLURMUSER=1002
groupadd -g $SLURMUSER slurm
useradd  -m -c "SLURM workload manager" -d /var/lib/slurm -u $SLURMUSER -g slurm -s /bin/bash slurm


sudo dnf install -y munge munge-libs munge-devel
sudo systemctl enable munge

# Retrieve the munge key from the master node
export ipmaster=192.168.132.60
scp -o StrictHostKeyChecking=no root@$ipmaster:/home/vagrant/munge.key /home/vagrant/munge.key
mv /home/vagrant/munge.key /etc/munge/munge.key



#  ######  BACKUP ....

# chown munge:munge /etc/munge/munge.key
# chown -R munge:munge /etc/munge /var/log/munge /var/run/munge
# chmod 700 /etc/munge
# chmod 400 /etc/munge/munge.key

#### Tenativo bis
chown munge:munge /etc/munge/munge.key
chown -R munge:munge /etc/munge /var/log/munge /var/run/munge
mkdir -p /runu/munge
chmod 0755 /run/munge
chown munge:munge /run/munge
chmod 0600 /etc/munge/munge.key


systemctl start munge


######      INSTALL SLURM       ######
sudo dnf install -y slurm-slurmd slurm-pam_slurm

rm -f /etc/slurm/slurm.conf
cat << EOF | sudo tee /etc/slurm/slurm.conf
ClusterName=slurmcluster
SlurmctldHost=ex3-00
ProctrackType=proctrack/linuxproc

ReturnToService=2

SlurmctldPidFile=/run/slurmctld.pid

SlurmdPidFile=/run/slurmd.pid

SlurmdSpoolDir=/var/lib/slurm/slurmd

StateSaveLocation=/var/lib/slurm/slurmctld

SlurmUser=slurm

TaskPlugin=task/none

SchedulerType=sched/backfill

SelectType=select/cons_tres

SelectTypeParameters=CR_Core_Memory

AccountingStorageType=accounting_storage/none

JobCompType=jobcomp/none

JobAcctGatherType=jobacct_gather/none

SlurmctldDebug=info

SlurmctldLogFile=/var/log/slurm/slurmctld.log

SlurmdDebug=info

SlurmdLogFile=/var/log/slurm/slurmd.log

NodeName=ex3-00 NodeAddr=192.168.132.60 CPUs=2 RealMemory=1464
NodeName=ex3-01 NodeAddr=192.168.132.61 CPUs=2 RealMemory=1464
NodeName=ex3-02 NodeAddr=192.168.132.62 CPUs=2 RealMemory=1464

# PartitionName ################################################################
#
# Name by which the partition may be referenced (e.g. "Interactive").  This
# name can be specified by users when submitting jobs. If the PartitionName is
# "DEFAULT", the values specified with that record will apply to subsequent
# partition specifications unless explicitly set to other values in that
# partition record or replaced with a different set of default values. Each
# line where PartitionName is "DEFAULT" will replace or add to previous default
# values and not a reinitialize the default values.

PartitionName=debug Nodes=ALL Default=YES MaxTime=INFINITE State=UP
EOF

systemctl enable slurmd
systemctl start slurmd

chown -R slurm:slurm /var/spool/slurm/



########## Set the right permission also there:

mkdir -p /run/slurm
chmod 0755 /run/slurm
chown -R slurm:slurm /run/slurm
mkdir -p /var/spool/slurm
chown -R slurm:slurm /var/spool/slurm
chown -R slurm:slurm /var/log/slurm
