#!/bin/bash
sudo yum update -y
sudo yum install httpd -y
sudo service httpd start
sudo chkconfig httpd on
sudo yum install -y amazon-efs-utils
sudo mount -t efs -o tls fs-443f29f1:/ /var/www/html
sudo cd /var/www/html
sudo echo "<html><body><h1>Welcome to our awesome stackcloud6</html></body></h1>" >index.html