#!/bin/bash

j=0

while true 
do
	i=$(( j % 3 + 1))
	status=$(docker exec -ti $(docker ps -q --filter "name=haproxy") curl -o /dev/null -s -w "%{http_code}\n" http://patroni$i:8091)
	echo "status patroni$i - $status"
	if [[ $status = 200 ]]
	then
    echo "host patroni$i down..."
    docker service scale patroni_patroni$i=0
	fi
	sleep 1
	((j++))
done


