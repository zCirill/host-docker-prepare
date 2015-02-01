#!/bin/bash

NAMEE=$1

#PSWD=$2

ID_DSA_PUB=$2

usermod -aG docker $NAMEE
mkdir /home/$NAMEE/.ssh
echo $ID_DSA_PUB > /home/$NAMEE/.ssh/authorized_keys
chmod 700 /home/$NAMEE/.ssh 
chmod 600 /home/$NAMEE/.ssh/authorized_keys 
chown $NAMEE.$NAMEE -R /home/$NAMEE/.ssh/

