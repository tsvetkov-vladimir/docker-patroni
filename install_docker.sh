#!/bin/bash

apt update

apt -y install apt-transport-https ca-certificates curl gnupg2 software-properties-common postgresql-client

curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -

add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"

apt update

apt -y install docker-ce

curl -L https://github.com/docker/compose/releases/download/1.25.3/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose

chmod +x /usr/local/bin/docker-compose

systemctl status --no-pager docker

docker-compose --version

mkdir -p /data/patroni/{main1,main2,main3}

useradd -d /data/patroni/ -s /bin/bash -u 503 postgres

chown postgres:postgres -R /data/patroni

chmod 0700 -R /data/patroni/*

#docker swarm init

#docker node ls

