#!/bin/bash
# display log
exec > >(tee /var/log/test.log|logger -t test -s 2>/dev/console) 2>&1
# update system
sudo yum update -y
# create a partition for attached EBS volumes
ebs_vol="/dev/sdb /dev/sdc /dev/sdd /dev/sde"
for var in ${ebs_vol}
do 
sudo fdisk $var <<EOT
n
P
1
2048
16777215
w
EOT
done
# Create disks labels (create physical volumes)
sudo pvcreate /dev/sdb1 /dev/sdc1 /dev/sdd1 /dev/sde1
# Create a volume group ( named stack_vg)
sudo vgcreate stack_vg /dev/sdb1 /dev/sdc1 /dev/sdd1 /dev/sde1
# Create logical volumes allocating about 5G
sudo lvcreate -L 5G -n Lv_u01 stack_vg
sudo lvcreate -L 5G -n Lv_u02 stack_vg
sudo lvcreate -L 5G -n Lv_u03 stack_vg
sudo lvcreate -L 5G -n Lv_u04 stack_vg
# Create ext4 filesystems on these logical volumes
sudo mkfs.ext4 /dev/stack_vg/Lv_u01
sudo mkfs.ext4 /dev/stack_vg/Lv_u02
sudo mkfs.ext4 /dev/stack_vg/Lv_u03
sudo mkfs.ext4 /dev/stack_vg/Lv_u04
# Create new directory for logical volumes
sudo mkdir /u01
sudo mkdir /u02
sudo mkdir /u03
sudo mkdir /u04
# Mount logical volumes to newly created directories
sudo mount /dev/stack_vg/Lv_u01 /u01
sudo mount /dev/stack_vg/Lv_u02 /u02
sudo mount /dev/stack_vg/Lv_u03 /u03
sudo mount /dev/stack_vg/Lv_u04 /u04
