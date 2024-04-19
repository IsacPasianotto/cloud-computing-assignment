#!/bin/bash

# Login as root, as some of the commands require root access
sudo su 


### Populate /etc/hosts file with the IP addresses and hostnames of the nodes in the cluster

echo "" >> /etc/hosts
echo "192.168.132.60 ex3-00 ex3-00" >> /etc/hosts
echo "192.168.132.61 ex3-01 ex3-01" >> /etc/hosts
echo "192.168.132.62 ex3-02 ex3-02" >> /etc/hosts

####  Set the NFS server on the master node


dnf install -y nfs-utils libnfsidmap sssd-nfs-idmap
systemctl enable --now nfs-server.service

mkdir -p /home/vagrant
mkdir -p /home/vagrant/shared
chown nobody:nobody /home/vagrant/shared
chmod 777 /home/vagrant/shared
mkdir -p /export/home
mkdir -p /export/home/vagrant
mkdir -p /export/home/vagrant/shared
sudo chown nobody:nobody /export/home/vagrant
sudo chmod 777 /export/home/vagrant/shared
echo '/export/home/vagrant/shared *(rw,sync,no_subtree_check,no_root_squash)' | sudo tee -a /etc/exports

echo "ex3-00:/export/home/vagrant/shared /home/vagrant/shared nfs defaults 0 0" | sudo tee -a /etc/fstab

exportfs -a
mount -t nfs ex3-00:/export/home/vagrant/shared /home/vagrant/shared

systemctl enable --now nfs-client

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

# Generate the munge key
# dd if=/dev/urandom bs=1 count=1024 | sudo tee /etc/munge/munge.key > /dev/null


#  ######  BACKUP ....
#
# sudo -u munge /usr/sbin/mungekey --verbose
# chown munge:munge /etc/munge/munge.key
# chown -R munge:munge /etc/munge /var/log/munge /var/run/munge
# chmod 700 /etc/munge
# chmod 400 /etc/munge/munge.key

#### Tentativo bis
sudo -u munge /usr/sbin/mungekey --verbose
chown munge:munge /etc/munge/munge.key
chown -R munge:munge /etc/munge /var/log/munge /var/run/munge
mkdir -p /runu/munge
chmod 0755 /run/munge
chown munge:munge /run/munge
chmod 0600 /etc/munge/munge.key


# only to be able to copy the key from other nodes
cp /etc/munge/munge.key /home/vagrant/munge.key
chown vagrant:vagrant /home/vagrant/munge.key
chmod 666 /home/vagrant/munge.key

systemctl start munge

####### Install Slurm  ###########

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

dnf install -y slurm-slurmctld
systemctl enable slurmctld
systemctl start slurmctld
systemctl enable slurmd
systemctl start slurmd



###### Set the right permission also there:
mkdir -p /run/slurm
chmod 0755 /run/slurm
chown -R slurm:slurm /run/slurm
mkdir -p /var/spool/slurm
chown -R slurm:slurm /var/spool/slurm
chown -R slurm:slurm /var/log/slurm
