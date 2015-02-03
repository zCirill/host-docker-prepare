#!/bin/bash

#делаем пид для последующего управления скриптом
[ -f /var/run/docker-log.analyser.pid ] && pkill -P `cat /var/run/docker-log.analyser.pid`
echo $$ > /var/run/docker-log.analyser.pid

DOCKER_DOMAN=.`hostname`

DOCKER_RESTART () {
GET_NAME
GET_IP
RECORD_CHANGE
}

GET_NAME () {
DOCKER_JOB=`echo $n | cut -f4 -d\[ | cut -f1 -d\]`
DOCKER_ID=`echo $n | cut -f4 -d"/" | cut -f1 -d"?"` 
DOCKER_NAME=`docker inspect --format '{{ .Name }}' $DOCKER_ID | cut -f2 -d"/"`
logger "docker job $DOCKER_JOB"
logger "true name docker is $DOCKER_NAME"
}

GET_IP () {
DOCKER_IP=`docker inspect --format '{{ .NetworkSettings.IPAddress }}' $DOCKER_NAME`
logger "$DOCKER_NAME $DOCKER_IP"
}

RECORD_CHANGE () {
#удаляем строку
sed -i "/$DOCKER_NAME$DOCKER_DOMAN/d" /etc/docker-container-hosts
logger "delete $DOCKER_NAME$DOCKER_DOMAN"
#добавляем строку
echo "$DOCKER_IP $DOCKER_NAME$DOCKER_DOMAN" >> /etc/docker-container-hosts
logger "add $DOCKER_NAME$DOCKER_DOMAN"
pkill -x -HUP dnsmasq
logger "dnsmasq reload"
}

DOCKER_DELETE () {
GET_NAME
GET_IP
#удаляем строку
sed -i "/$DOCKER_NAME$DOCKER_DOMAN/d" /etc/docker-container-hosts
logger "delete $DOCKER_NAME$DOCKER_DOMAN"
pkill -x -HUP dnsmasq
logger "dnsmasq reload"
}

#прицепляемся к логу и начинаем искать вхождения

tail -F /var/log/upstart/docker.log | while read n; do
# if [[ $n =~ "-job restart" && $n =~ "OK (0)" ]] ; then DOCKER_RESTART
# fi
 if [[ $n =~ "POST" && $n =~ "start" ]] ; then DOCKER_RESTART
 fi
# if [[ $n =~ "-job stop" && $n =~ "OK (0)" ]] ; then DOCKER_STOP
# fi
 if [[ $n =~ "DELETE" ]] ; then DOCKER_DELETE 
 fi

done

