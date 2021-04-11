#!/bin/bash
sudo su -
yum update -y
yum install -y nfs-utils
FILE_SYSTEM_ID=fs-ac766719
AVAILABILITY_ZONE=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone )
REGION=${AVAILABILITY_ZONE:0:-1}
MOUNT_POINT=/var/www/html
mkdir -p ${MOUNT_POINT}
chown ec2-user:ec2-user ${MOUNT_POINT}
echo ${FILE_SYSTEM_ID}.efs.${REGION}.amazonaws.com:/ ${MOUNT_POINT} nfs4 nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,_netdev 0 0 >> /etc/fstab
mount -a -t nfs4
chmod -R 755 /var/www/html
sudo su - ec2-user
sudo amazon-linux-extras install -y lamp-mariadb10.2-php7.2 php7.2
sudo yum install -y httpd mariadb-server
sudo systemctl start httpd
sudo systemctl enable httpd
sudo systemctl is-enabled httpd
sudo usermod -a -G apache ec2-user
sudo chown -R ec2-user:apache /var/www
sudo chmod 2775 /var/www && find /var/www -type d -exec sudo chmod 2775 {} \;
find /var/www -type f -exec sudo chmod 0664 {} \;
sudo systemctl start mariadb
aws s3 cp s3://mystacks3website/index.html /var/www/html
aws s3 cp s3://mystacks3website/Stack_IT_Logo.png /var/www/html