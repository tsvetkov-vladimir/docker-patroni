#!/bin/bash

j=0
k=0

while true 
do
	i=$(( j % 3 + 1))
	status=$(docker exec -ti "$(docker ps -q --filter "name=haproxy")" curl -o /dev/null -s -w "%{http_code}\n" http://patroni$i:8091)
	echo "status patroni$i - ${status}"
	status="$(echo -e "${status}" | tr -d '[:space:]')"
	if [[ ${status} = 200 ]]
	then
    echo "host patroni$i down..."
    sleep 30
    docker service scale patroni_patroni$i=0
    ((k++))
  elif [[ ${k} = 3 ]]
  then
    for k in 3 2 1
    do
      echo "host patroni$k up..."
      sleep 10
      docker service scale patroni_patroni$k=1
    done
    k=0
	fi
	sleep 1
	((j++))
done


