--Jenkins Installation 
sudo yum -y remove java
sudo yum -y install java-1.8.0-openjdk
sudo wget -O /etc/yum.repos.d/jenkins.repo http://pkg.jenkins-ci.org/redhat-stable/jenkins.repo
sudo rpm --import https://jenkins-ci.org/redhat/jenkins-ci.org.key
--website
sudo rpm --import https://jenkins-ci.org/redhat/jenkins-ci.org.key
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
sudo yum -y install jenkins
sudo systemctl enable jenkins
sudo systemctl start jenkins


sudo systemctl status jenkins


--view jenkins log 
sudo tail -f /var/log/jenkins/jenkins.log


--ip :8080

--jenkins pw
/var/lib/jenkins/secrets/initialAdminPassword
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
