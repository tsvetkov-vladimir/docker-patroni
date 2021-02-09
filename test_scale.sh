#!/bin/bash

j=0

while true 
do
	i=$(( $j % 3 ))
	echo $i
	sleep 1
	((j++))
done

docker service scale patroni_patroni3=0
