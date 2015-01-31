#!/bin/bash

docker stop skydock
docker stop skydns
docker rm skydock
docker rm skydns

docker run -d -p 172.17.42.1:53:53/udp -p 172.17.42.1:8080:8080 --name skydns crosbymichael/skydns -nameserver 8.8.8.8:53 -domain local

docker run -d -v /var/run/docker.sock:/docker.sock --name skydock --link skydns:skydns crosbymichael/skydock -ttl 30 -environment dev -s /docker.sock -domain local

echo "nameserver 172.17.42.1" > /etc/resolv.conf
echo "nameserver 8.8.8.8" >> /etc/resolv.conf

