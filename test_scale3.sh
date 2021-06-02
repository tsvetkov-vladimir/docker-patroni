#!/bin/bash

j=0
k=0
m=0
flag=false

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

psql postgresql://postgres:supass@127.0.0.1:5000 -tc "SELECT 1 FROM pg_database WHERE datname = 'test'" | grep -q 1 || psql postgresql://postgres:supass@127.0.0.1:5000  -c "CREATE DATABASE test"

psql postgresql://postgres:supass@127.0.0.1:5000/test -tc "CREATE TABLE IF NOT EXISTS test (id SERIAL);"

#if ! psql postgresql://postgres:supass@127.0.0.1:5000 -f create.sql
#then
#  echo "error psql";
#  exit 1;
#fi

./test_insert.sh &

arr_deg=()
# бесконечный цикл по деградации и восстановления роя
while true
do
	i=$(( j % 3 + 1))
	status=$(docker exec -ti "$(docker ps -q | head -n 1)" curl -o /dev/null -s -w "%{http_code}\n" http://patroni${i}:8091)
	echo "status patroni${i} - ${status}"
	status="$(echo -e "${status}" | tr -d '[:space:]')"

# блок для формирования признака полной деградации роя в случае, когда тест был запущен при частичной деградации
	if [[ ${status} = 000 && ${flag} = false ]]
	then
	  flag=true
	  ((m++))
	elif [[ ${status} = 000 && ${flag} = true ]]
	then
	  ((m++))
	else
	  m=0
	  flag=false
	fi

# блок имитации аварии на мастере
	if [[ ${status} = 200 && ${k} < 2 ]]
	then
    printf "\e[1;31mhost patroni$i down after 30 sec\e[m\n"
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
    printf "\n"
    printf "\e[1;31mhost patroni$i down...\e[m\n"
    docker service scale patroni_patroni${i}=0
    arr_deg+=(${i})
    ((k++))
# блок восстановления роя
#    echo "k = ${k}, m = ${m}"
  elif [[ ${k} = 2 || ${m} = 2 ]] && [[ ${status} = 200 ]]
  then
    printf "\e[42mRecovery cluster start after 60 sec...\e[m\n"
    _start=1
    _end=600
    for number in $(seq ${_start} ${_end})
    do
      sleep 0.1
      ProgressBar ${number} ${_end}
    done
    printf "\n"
    printf "\e[1;32mRecovery cluster start...\e[m\n"
#    docker exec -it $(docker ps -q -f name=patroni_haproxy) /bin/bash -c "sed -i 's/.*patroni/# \0/' /usr/local/etc/haproxy/haproxy.cfg"
    for k in 0 1
    do
      # формируем случайный номер восстанавливаемого узла
      printf "\e[1;32mhost patroni${arr_deg[${k}]} up...\e[m\n"
      docker service scale patroni_patroni${arr_deg[${k}]}=1
#      docker exec -it $(docker ps -q -f name=patroni_haproxy) /bin/bash -c "sed -i '/^#.*patroni${n}/s/^#//' /usr/local/etc/haproxy/haproxy.cfg"
#      docker exec -it $(docker ps -q -f name=patroni_haproxy) /bin/bash -c 'kill -s HUP $(pidof haproxy)'
#      if [[ ${k} < 3 ]]; then
        docker exec -it $(docker ps -q -f name=patroni_haproxy) /bin/bash -c "curl -s http://patroni${arr_deg[${k}]}:8091/reinitialize -XPOST -d '{\"force\":true}'"
#      fi
      printf "\n"
      printf "\e[1;32mRun patroni${arr_deg[${k}]} 30 sec\e[m\n"
      _start=1
      _end=300
      for number in $(seq ${_start} ${_end})
      do
        sleep 0.1
        ProgressBar ${number} ${_end}
      done
      printf "\n"
    done
    k=0
    arr_deg=()
	fi
	sleep 1
	((j++))
done
