#!/bin/bash

if [ -z "$1" ] ; then echo "set correct ip to docker service" && exit 1
fi

sed -i s/ru.archive.ubuntu.com/mirror.yandex.ru/g /etc/apt/sources.list

apt-get update && apt-get install curl

curl -sSL https://get.docker.com/ubuntu/ | sh

echo DOCKER_OPTS=\"--bip=$1/16 --dns $1 --dns 8.8.8.8\" > /etc/default/docker

service docker restart
