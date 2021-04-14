#!/bin/bash

j=0
k=0

# 1. Create ProgressBar function
# 1.1 Input is currentState($1) and totalState($2)
ProgressBar() {
# Process data
    let _progress=(${1}*100/${2}*100)/100
    let _done=(${_progress}*4)/10
    let _left=40-$_done
# Build progressbar string lengths
    _fill=$(printf "%${_done}s")
    _empty=$(printf "%${_left}s")

# 1.2 Build progressbar strings and print the ProgressBar line
# 1.2.1 Output example:
# 1.2.1.1 Progress : [########################################] 100%
printf "\rProgress : [${_fill// /#}${_empty// /-}] ${_progress}%%"

}

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
    echo "host patroni$i down after 30 sec"
    # Variables
    _start=1

    # This accounts as the "totalState" variable for the ProgressBar function
    _end=300

    # Proof of concept
    for number in $(seq ${_start} ${_end})
    do
      sleep 0.1
      ProgressBar ${number} ${_end}
    done
    echo "host patroni$i down..."
    docker service scale patroni_patroni$i=0
    ((k++))
  elif [[ ${k} = 3 ]]
  then
    :
	fi
	sleep 1
	((j++))
done
