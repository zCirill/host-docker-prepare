#!/bin/bash

if [ -z "$1" ] ; then echo "set correct ip to docker service" && exit 1
fi

curl -sSL https://get.docker.com/ubuntu/ | sh

echo DOCKER_OPTS="--bip=$1/16 --dns $1 --dns 8.8.8.8" > /etc/default/docker

service docker restart
