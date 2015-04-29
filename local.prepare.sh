curl -sSL https://get.docker.com/ubuntu/ | sh

echo DOCKER_OPTS=\"--bip=172.17.42.1/16 --dns 172.17.42.1 --dns 8.8.8.8\" > /etc/default/docker

service docker restart

bash prepare.dnsmasq.sh
