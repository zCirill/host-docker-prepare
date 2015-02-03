#!/bin/bash

mkdir /var/www
mkdir /var/www/dev
mkdir /var/www/stage
mkdir /var/www/production
mkdir /var/www/keys
chmod 700 /var/www/keys
chown ft-deploy.ft-deploy -R /var/www/
chmod g+s -R /var/www/

#ft-deploy ALL=NOPASSWD: /etc/init.d/nginx reload
#ft-deploy ALL=NOPASSWD: /bin/chown -R ft-deploy /var/www/*


