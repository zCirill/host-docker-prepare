#!/bin/bash

#делаем пид для последующего управления скриптом
[ -f /var/run/docker-log.analyser.pid ] && pkill -P `cat /var/run/docker-log.analyser.pid`
echo $$ > /var/run/docker-log.analyser.pid

DOCKER_DOMAIN=.`hostname`
DOCKER_DOMAIN2=.local

DOCKER_START () {
GET_NAME
if [ -n "$DOCKER_NAME" ] ; then GET_IP && RECORD_CHANGE
fi
}

DOCKER_RESTART () {
GET_NAME
if [ -n "$DOCKER_NAME" ] ; then GET_IP && RECORD_CHANGE
fi
}

DOCKER_RENAME () {
GET_NAME_B
DNS_NAME_DELETE
GET_NAME_A
DNS_NAME_ADD
DNS_RELOAD
}

GET_NAME_R () {
DOCKER_JOB=`echo $n | cut -f4 -d\[ | cut -f1 -d\]`
DOCKER_ID=`echo $n | cut -f2 -d\( | cut -f1 -d\)`
DOCKER_NAME=`docker inspect --format '{{ .Name }}' $DOCKER_ID | cut -f2 -d"/"`
logger "docker job $DOCKER_JOB"
logger "true name docker is $DOCKER_NAME"
}

GET_NAME () {
DOCKER_JOB=`echo $n | cut -f4 -d\[ | cut -f1 -d\]`
DOCKER_ID=`echo $n | cut -f4 -d"/" | cut -f1 -d"?"` 
DOCKER_NAME=`docker inspect --format '{{ .Name }}' $DOCKER_ID | cut -f2 -d"/"`
logger "docker job $DOCKER_JOB"
logger "true name docker is $DOCKER_NAME"
}

GET_NAME_B () {
DOCKER_JOB=`echo $n | cut -f4 -d\[ | cut -f1 -d\]`
DOCKER_NAME=`echo $n | cut -f4 -d"/" | cut -f1 -d"?"`
logger "docker RENAME job $DOCKER_JOB"
logger "name docker BEFORE RENAME is $DOCKER_NAME"
}


GET_NAME_A () {
DOCKER_JOB=`echo $n | cut -f4 -d\[ | cut -f1 -d\]`
DOCKER_NAME=`echo $n | cut -f5 -d"/" | cut -f2 -d"?" | cut -f1 -d" " | cut -f2 -d\=`
logger "docker RENAME job $DOCKER_JOB"
logger "name docker AFTER RENAME is $DOCKER_NAME"
GET_IP
}

DNS_NAME_DELETE () {
sed -i "/$DOCKER_NAME$DOCKER_DOMAIN/d" /etc/docker-container-hosts
sed -i "/$DOCKER_NAME$DOCKER_DOMAIN2/d" /etc/docker-container-hosts
logger "delete $DOCKER_NAME$DOCKER_DOMAIN"
logger "delete $DOCKER_NAME$DOCKER_DOMAIN2"
}

DNS_NAME_ADD () {
echo "$DOCKER_IP $DOCKER_NAME$DOCKER_DOMAIN" >> /etc/docker-container-hosts
echo "$DOCKER_IP $DOCKER_NAME$DOCKER_DOMAIN2" >> /etc/docker-container-hosts
logger "add $DOCKER_NAME$DOCKER_DOMAIN"
logger "add $DOCKER_NAME$DOCKER_DOMAIN2"
}

GET_IP () {
DOCKER_IP=`docker inspect --format '{{ .NetworkSettings.IPAddress }}' $DOCKER_NAME`
logger "$DOCKER_NAME $DOCKER_IP"
}

RECORD_CHANGE () {
DNS_NAME_DELETE
DNS_NAME_ADD
DNS_RELOAD
}


DOCKER_DELETE () {
GET_NAME
GET_IP
#удаляем строку
sed -i "/$DOCKER_NAME$DOCKER_DOMAIN/d" /etc/docker-container-hosts
sed -i "/$DOCKER_NAME$DOCKER_DOMAIN2/d" /etc/docker-container-hosts
logger "delete $DOCKER_NAME$DOCKER_DOMAIN"
pkill -x -HUP dnsmasq
logger "dnsmasq reload"
}

DNS_RELOAD () {
sed -i /^" "/d /etc/docker-container-hosts
pkill -x -HUP dnsmasq
logger "dnsmasq reload"
}

#прицепляемся к логу и начинаем искать вхождения

tail -F -n0 /var/log/upstart/docker.log | while read n; do

 if [[ $n =~ "POST" && $n =~ "/restart" ]] ; then DOCKER_RESTART
 fi
 if [[ $n =~ "POST" && $n =~ "/start" ]] ; then DOCKER_START
 fi
 if [[ $n =~ "POST" && $n =~ "/rename" ]] ; then DOCKER_RENAME
 fi

done

