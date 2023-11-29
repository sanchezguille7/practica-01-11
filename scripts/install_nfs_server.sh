#!/bin/bash
set -ex

apt-get update

apt-get upgrade -y

source .env

apt install nfs-kernel-server -y

mkdir -p /var/www/html

chown nobody:nogroup /var/www/html

cp ../exports/exports /etc/exports

sed -i "s#NFS_FRONTEND_NETWORK#$NFS_FRONTEND_NETWORK#" /etc/exports

systemctl restart nfs-kernel-server

#df -h