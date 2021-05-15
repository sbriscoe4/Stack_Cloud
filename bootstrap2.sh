#!/bin/bash
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
#sudo mysql_secure_installation
sudo systemctl enable mariadb
sudo yum install php-mbstring -y
sudo yum install php-xml -y
sudo systemctl restart httpd
sudo systemctl restart php-fpm
####DOWNLOAD PHPMYADMIN #####
cd /var/www/html
wget https://www.phpmyadmin.net/downloads/phpMyAdmin-latest-all-languages.tar.gz
mkdir phpMyAdmin && tar -xvzf phpMyAdmin-latest-all-languages.tar.gz -C phpMyAdmin --strip-components 1
rm phpMyAdmin-latest-all-languages.tar.gz
#aws s3 cp s3://stackwpshavon /var/www/html/ --recursive
sudo yum install git -y
git clone https://github.com/stackitgit/CliXX_Retail_Repository.git
cp -r CliXX_Retail_Repository/* /var/www/html 
sudo chkconfig httpd on
sudo systemctl status httpd
#####INSTALL WORDPRESS####
cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php
#cp -r wordpress/* /var/www/html/
sudo sed -i 's/database_name_here/${DB_NAME}/' /var/www/html/wp-config.php
sudo sed -i 's/username_here/${DB_USER}/' /var/www/html/wp-config.php
sudo sed -i 's/password_here/${DB_PASSWORD}/' /var/www/html/wp-config.php
sudo sed -i 's/localhost/${RDS_ENDPOINT}/' /var/www/html/wp-config.php
## Allow wordpress to use Permalinks###
sudo sed -i '151s/None/All/' /etc/httpd/conf/httpd.conf
###CHANGE OWNERSHIP FOR APACHE AND RESTART SERVICES###
sudo chown -R apache /var/www
sudo chgrp -R apache /var/www
sudo chmod 2775 /var/www
find /var/www -type d -exec sudo chmod 2775 {} \;
find /var/www -type f -exec sudo chmod 0664 {} \;
sudo systemctl restart httpd
sudo systemctl enable httpd && sudo systemctl enable mariadb
sudo systemctl status mariadb
sudo systemctl start mariadb
sudo systemctl status httpd
sudo systemctl start httpd

#HOW TO MAKE BOOTSTRAP GENERATE A SCRIPT
sudo /bin/cat <<EOF >/home/ec2-user/postinstall.sh
mysql -h ${RDS_ENDPOINT} -D ${DB_NAME} -u\${DB_USER} -p\${DB_PASSWORD} <<EOT
use ${DB_NAME};
UPDATE wp_options SET option_value = "http://${LB_DNS}" WHERE option_value LIKE 'http%';
EOT
EOF
sudo chmod 755 /home/ec2-user/postinstall.sh
sudo /home/ec2-user/postinstall.sh