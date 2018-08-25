#! /bin/bash

yum clean all
yum -y update
yum -y install httpd

curl -O http://www.scriptcha.com/scriptcha.zip
unzip scriptcha.zip

firewall-cmd --permanent --add-port=80/tcp
firewall-cmd --permanent --add-port=443/tcp

firewall-cmd --reload

rm -rf /etc/httpd/conf.d/welcome.conf
rm -rf /etc/httpd/conf.d/userdir.conf

cp -r ./scriptcha/conf/userdir.conf /etc/httpd/conf.d/userdir.conf
cp -r ./scriptcha/www/index.html /var/www/html/index.html
cp -r ./scriptcha/sudoers.d/scriptcha /etc/sudoers.d/scriptcha
cp -r ./scriptcha/conf/scriptcha.conf /etc/httpd/conf.d/scriptcha.conf

systemctl start httpd
systemctl enable httpd

yum -y install epel-release
yum-config-manager --enable remi-php72

yum -y update
yum -y install php
yum -y install mod_ruid2

mkdir -p /usr/local/scriptcha/
mkdir -p /usr/local/scriptcha/web
chown -R $USER:$USER /usr/local/scriptcha/web

apachectl restart
