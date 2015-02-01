#!/bin/bash

#делаем пид для последующего управления скриптом
[ -f /var/run/docker-log.analyser.pid ] && pkill -P `cat /var/run/docker-log.analyser.pid`
echo $$ > /var/run/docker-log.analyser.pid

DOCKER_DOMAN=.dev.local

DOCKER_RESTART () {
GET_NAME
GET_IP
RECORD_CHANGE
}

GET_NAME () {
DOCKER_ID=`echo $n | cut -f2 -d"(" | cut -f1 -d")"` 
DOCKER_NAME=`docker inspect --format '{{ .Name }}' $DOCKER_ID | cut -f2 -d"/"`
#echo "true name docker is $DOCKER_NAME"
}

GET_IP () {
DOCKER_IP=`docker inspect --format '{{ .NetworkSettings.IPAddress }}' $DOCKER_NAME`
#echo $DOCKER_IP
}

RECORD_CHANGE () {
#удаляем строку
sed -i "/$DOCKER_NAME$DOCKER_DOMAN/d" /etc/docker-container-hosts
#добавляем строку
echo "$DOCKER_IP $DOCKER_NAME$DOCKER_DOMAN" >> /etc/docker-container-hosts
pkill -x -HUP dnsmasq
}

DOCKER_RM () {
#удаляем строку
sed -i "/$DOCKER_NAME$DOCKER_DOMAN/d" /etc/docker-container-hosts
pkill -x -HUP dnsmasq
}

#прицепляемся к логу и начинаем искать вхождения

tail -F /var/log/upstart/docker.log | while read n; do
 if [[ $n =~ "-job restart" && $n =~ "OK (0)" ]] ; then DOCKER_RESTART
 fi
 if [[ $n =~ "-job start" && $n =~ "OK (0)" ]] ; then DOCKER_RESTART
 fi
# if [[ $n =~ "-job stop" && $n =~ "OK (0)" ]] ; then DOCKER_STOP
# fi
 if [[ $n =~ "-job rm" && $n =~ "OK (0)" ]] ; then DOCKER_RM 
 fi

done

