#! /bin/bash

echo "Just downloading few things before we start installing Scriptcha Control Panel.";
curl -O -s 'http://www.scriptcha.com/scriptcha.zip' > /dev/null
unzip scriptcha.zip > /dev/null

echo "Checking status of SELinux";
SELINUXSTATUS=$(getenforce);
if [ "$SELINUXSTATUS" != "Disabled" ]; then
  	setenforce 0;
	echo "ERROR: SELinux is enabled in this server. SELinux causes issue with Scriptcha Control Panel from working properly. Please disable SELinux permanently, restart your server and then re-run this script.";
	exit;
fi;

echo 
yum clean all
#yum -y update

echo "Installing Apache";
yum -y install httpd

echo "Adding required ports to firewall";
firewall-cmd --permanent --add-port=80/tcp
firewall-cmd --permanent --add-port=443/tcp
firewall-cmd --reload

echo "Copying and removing few default installation";
rm -rf /etc/httpd/conf.d/welcome.conf
rm -rf /etc/httpd/conf.d/userdir.conf

cp -r ./scriptcha/conf/userdir.conf /etc/httpd/conf.d/userdir.conf
cp -r ./scriptcha/www/index.html /var/www/html/index.html
cp -r ./scriptcha/sudoers.d/scriptcha /etc/sudoers.d/scriptcha
cp -r ./scriptcha/conf/scriptcha.conf /etc/httpd/conf.d/scriptcha.conf

echo "Starting up Apache";
systemctl start httpd
systemctl enable httpd

yum -y install epel-release
yum-config-manager --enable remi-php72

echo "Installing PHP 7.2";
#yum -y update
yum -y install php
yum -y install mod_ruid2

mv ./scriptcha/html/www/index.html /var/www/html/index.html
mv ./scriptcha/src/* /usr/local/
chown -R $USER:$USER /usr/local/scriptcha/web

echo "Restarting Apache";
apachectl restart

echo "Congratulations! Scriptcha Control Panel has successfully been installed.";
