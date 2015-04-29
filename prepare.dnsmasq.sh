#!/bin/bash

sed -i s/ru.archive.ubuntu.com/mirror.yandex.ru/g /etc/apt/sources.list

echo "nameserver 8.8.8.8" > /etc/resolv.conf

#получаем адрес сервиса докера
IP=`grep ^DOCKER_OPTS /etc/default/docker | cut -f3 -d" "`

#установка dnsmasq
apt-get update && apt-get install -y dnsmasq

#конфигурация dnsmasq

echo "nameserver 8.8.8.8" > /etc/resolv_dnsqmasq.conf

echo -e "conf-dir=/etc/dnsmasq.d\nlisten-address=$IP\ninterface=docker0\nresolv-file=/etc/resolv_dnsqmasq.conf" > /etc/dnsmasq.conf

echo -e "addn-hosts=/etc/docker-container-hosts\ninterface=docker0" > /etc/dnsmasq.d/docker

touch /etc/docker-container-hosts

echo "nameserver $IP" > /etc/resolv.conf
echo "nameserver 8.8.8.8" >> /etc/resolv.conf
echo "search local" >> /etc/resolv.conf

service dnsmasq restart

cp init-conf/docker-log-analyser.conf /etc/init
cp docker-log-analyser.sh /usr/local/etc/docker-log-analyser.sh

start docker-log-analyser
