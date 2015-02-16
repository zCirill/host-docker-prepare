#!/bin/bash

DOCKER_DOMAN=`hostname`

docker ps -q | while read n; do docker inspect --format '{{ .Name }}' $n | cut -f2 -d"/"; done > docker.name

rm /etc/docker-container-hosts
touch /etc/docker-container-hosts

cat docker.name | while read n
	do IP=`docker inspect --format '{{ .NetworkSettings.IPAddress }}' $n` && echo $IP $n.$DOCKER_DOMAN >> /etc/docker-container-hosts \
	&& echo $IP $n.local >> /etc/docker-container-hosts
done

pkill -x -HUP dnsmasq

