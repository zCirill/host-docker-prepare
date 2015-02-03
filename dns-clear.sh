#!/bin/bash

docker ps -q | while read n; do docker inspect --format '{{ .Name }}' $n | cut -f2 -d"/"; done > docker.name


cat docker.name | while read n; do IP=`docker inspect --format '{{ .NetworkSettings.IPAddress }}' $n` && echo $IP $n.ftvcd01 >> 
/etc/docker-container-hosts; done

pkill -x -HUP dnsmasq
