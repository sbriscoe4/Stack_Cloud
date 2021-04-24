#!/bin/bash
sudo exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

su root -
#sudo yum update -y

#partition ebs volume disks
    sudo fdisk "/dev/sdb" <<EOT
    n
    p
    1
    
    
    w
EOT

    sudo fdisk "/dev/sdc" <<EOT
    n
    p
    1
    
    
    w

EOT

    sudo fdisk "/dev/sdd" <<EOT
    n
    p
    1
    
    
    w
EOT

    sudo fdisk "/dev/sde" <<EOT
    n
    p
    1
    
    
    w
EOT

#create disk lables
sudo pvcreate /dev/sdb1 /dev/sdc1 /dev/sdd1 /dev/sde1

#create volume group
sudo vgcreate stack_vg /dev/sdb1 /dev/sdc1 /dev/sdd1 /dev/sde1

#create logical volumses w/ 5g space
    sudo lvcreate -L 5G -n Lv_u01 stack_vg
    sudo lvcreate -L 5G -n Lv_u02 stack_vg
    sudo lvcreate -L 5G -n Lv_u03 stack_vg
    sudo lvcreate -L 5G -n Lv_u04 stack_vg


#create file systems on logical volumes 
    sudo mkfs.ext4 /dev/stack_vg/Lv_u01
    sudo mkfs.ext4 /dev/stack_vg/Lv_u02
    sudo mkfs.ext4 /dev/stack_vg/Lv_u03
    sudo mkfs.ext4 /dev/stack_vg/Lv_u04


#create mount points to hold the space for the logical volumnes
sudo mkdir /u01 
sudo mkdir /u02 
sudo mkdir /u03 
sudo mkdir /u04 

#mount created disks
sudo mount /dev/stack_vg/Lv_u01 /u01
sudo mount /dev/stack_vg/Lv_u02 /u02
sudo mount /dev/stack_vg/Lv_u03 /u03
sudo mount /dev/stack_vg/Lv_u04 /u04

#validate mount
df -h