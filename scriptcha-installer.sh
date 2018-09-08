#! /bin/bash

echo "Checking status of SELinux";
SELINUXSTATUS=$(getenforce);
if [ "$SELINUXSTATUS" != "Disabled" ]; then
  	setenforce 0;
	echo "ERROR: SELinux is enabled in this server. SELinux causes issue with Scriptcha Control Panel from working properly. Please disable SELinux permanently, restart your server and then re-run this script.";
	exit;
fi;

echo "Just downloading few things before we start installing Scriptcha Control Panel.";
curl -O -s 'http://www.scriptcha.com/scriptcha.zip' > /dev/null
unzip scriptcha.zip > /dev/null

yum clean all
#yum -y update

echo "Creating user"
adduser admin && echo "admin:C689yNJ6HBEUfHMw" | chpasswd

echo "Installing Apache";
yum -y install httpd

echo "Adding required ports to firewall";
firewall-cmd --permanent --add-port=80/tcp
firewall-cmd --permanent --add-port=443/tcp
firewall-cmd --permanent --add-port=8083/tcp
firewall-cmd --reload

echo "Copying and removing few default installation";
rm -rf /etc/httpd/conf.d/welcome.conf
rm -rf /etc/httpd/conf.d/userdir.conf

echo "Starting up Apache";
systemctl start httpd
systemctl enable httpd

yum -y install epel-release
yum-config-manager --enable remi-php72

echo "Installing PHP 7.2";
#yum -y update
yum -y install php
yum -y install php-pdo
yum -y install mod_ruid2

mv ./scriptcha/html/www/index.html /var/www/html/index.html
mv ./scriptcha/src/* /usr/local/
chown -R $USER:$USER /usr/local/scriptcha/web

cp -r ./scriptcha/conf/userdir.conf /etc/httpd/conf.d/userdir.conf
cp -r ./scriptcha/sudoers.d/admin /etc/sudoers.d/admin
cp -r ./scriptcha/conf/scriptcha.conf /etc/httpd/conf.d/scriptcha.conf
cp -r ./scriptcha/conf/php.ini /etc/php.ini

chmod 755 /usr/local/scriptcha/web/bin/login.sh
chmod 755 /usr/local/scriptcha/web/bin/settings.sh
chmod 755 /usr/local/scriptcha/web/bin/v-account.sh
chmod 755 /usr/local/scriptcha/web/bin/v-add-website.sh
chmod 755 /usr/local/scriptcha/web/bin/v-delete-website.sh
chmod 755 /usr/local/scriptcha/web/bin/v-GetUsername.sh
chmod 755 /usr/local/scriptcha/web/bin/vhost-exists.sh
chmod 755 /usr/local/scriptcha/web/bin/v-login.sh

echo "Restarting Apache";
apachectl restart

echo "Congratulations! Scriptcha Control Panel has successfully been installed.";
