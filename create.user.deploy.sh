#/bin/bash

mkdir -p /home/$1/.ssh 
useradd -g users -d /home/$1 -s /bin/bash -p $(echo $2 | openssl passwd -1 -stdin) $1 
echo $3 >> /home/$1/.ssh/authorized_keys
chown -R $1 /home/$1 && \
chmod 700 /home/$1/.ssh
usermod -aG docker $1
