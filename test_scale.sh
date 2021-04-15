#!/bin/bash

j=0
k=0

if ! psql postgresql://postgres:supass@127.0.0.1:5000 -f create.sql
then
  echo "error psql";
  exit 1;
fi

./test_insert.sh &

while true 
do
	i=$(( j % 3 + 1))
	status=$(docker exec -ti "$(docker ps -q | head -n 1)" curl -o /dev/null -s -w "%{http_code}\n" http://patroni$i:8091)
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
    docker exec -it $(docker ps -q -f name=patroni_patroni1) /bin/bash -c 'echo -e "patroni\nYes I am aware" > /tmp/ddd;patronictl -c /etc/patroni.yml remove patroni < /tmp/ddd'
    docker exec -it $(docker ps -q -f name=patroni_haproxy) /bin/bash -c 'kill -s HUP $(pidof haproxy)'
    k=0
	fi
	sleep 1
	((j++))
done


