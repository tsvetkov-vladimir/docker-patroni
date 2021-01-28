#!/bin/bash

cd etcd/
docker stack deploy --compose-file docker-compose-cluster.yml patroni

sleep 5

cd ../patroni/

docker stack deploy --compose-file docker-compose-patroni.yml patroni

sleep 5

cd ../haproxy/

docker stack deploy --compose-file docker-compose-haproxy.yml patroni

sleep

docker service ls