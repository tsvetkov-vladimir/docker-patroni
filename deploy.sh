#!/bin/bash

cd etcd/
docker stack deploy --compose-file docker-compose-cluster.yml patroni

cd ../patroni/

docker stack deploy --compose-file docker-compose-patroni.yml patroni

cd ../haproxy/

docker stack deploy --compose-file docker-compose-haproxy.yml patroni