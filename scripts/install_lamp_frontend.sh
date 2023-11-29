#!/bin/bash

set -ex

apt update

#apt upgrade -y

apt install apache2 -y
 
cp ../conf/000-default.conf /etc/apache2/sites-available/000-default.conf

sudo apt install php libapache2-mod-php php-mysql -y

systemctl restart apache2

chown -R www-data:www-data /var/www/html