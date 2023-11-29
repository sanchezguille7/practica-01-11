#!/bin/bash
set -ex

apt-get update

apt-get upgrade -y

source .env

apt install nfs-common -y

mount $NFS_SERVER_PRIVATE_IP:/var/www/html /var/www/html

# si creas un archivo en /vaw/www/html aqui tiene que aparecer en NFS_server

nano /etc/fstab

echo "$NFS_SERVER_PRIVATE_IP:/var/www/html /var/www/html  nfs auto,nofail,noatime,nolock,intr,tcp,actimeo=1800 0 0" >> /etc/fstab