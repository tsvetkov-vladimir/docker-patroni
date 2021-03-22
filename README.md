# docker-patroni

Пример установки и запуска patroni в среде Docker Swarm.

Предполагается, что установка выполняется на пустой машине с OS Debian 10.

Для тестирования и отладки использовались виртуальные машины созданные на ресурсе https://vscale.io.

## **Установка**

1. Устанавливаем git

`apt update`

`apt -y install git`

2. Клонируем репозиторий на каждый узел кластера

`git clone https://github.com/tsvetkov-vladimir/docker-patroni.git`

3. Устанавливаем docker и docker-compose на каждом узле кластера

`cd docker-patroni/`

`./install_docker.sh`

4. Проверка результата установки

`systemctl status docker`

`docker-compose --version`

## **Создание образов patroni и haproxy**

1. Выполняем команду на каждом узле

`./create_images.sh`

## **Запуск Docker swarm**

1. Выполняем команду на управляющем узле

`docker swarm init`

`docker node ls`

2. Для присоединения узла в качестве докера необходимо на присоединяемом узле выполнить команду

`docker swarm join --token SWMTKN-1-4nxtulbtj38n3v782satsnat3eu8lm7e74ir7u6i05nepjtwe6-c61idt643vdxrs7llpjkrvsl2 82.148.18.190:2377`

## **Запуск сервисов в кластере**

1. Выполняем команду на управляющем узле

`./deploy.sh`

## **Команды проверки сервиса**

1. Проверка запуска сервисов (команда выполняется только на управляющем узле)

`docker service ls`

Следует обратить внимание на поле REPLICAS,
в первой позиции указывается фактическое количество запущенных задач,
во второй позиции указывается требуемое количество задач.
Идеально состояние это когда эти позиции совпадают.
Если в первой позиции значение равно 0, то однозначно это означает,
что имеются проблемы запуска

2. Проверка запуска задач сервисов (команда выполняется только на управляющем узле)

`docker stack ps patroni`

Следует обратить внимание на поле ERROR. При успешном функционировании задач
в этом поле не должно быть ошибок.
В поле DESIRED должно быть значение - Running

3. Проверка запущенных контейнеров (команда может выполняться на любом узле)

`docker ps`

С помощью этой команды можно посмотреть как распределились запущенные контейнера по узлам кластера

4. Проверка через сервис haproxy

Запустить браузер и адресной строке браузера ввести адрес

http://81.163.28.31:7000

Где: адрес сервера -- это адрес узла где запущен docker

4. Имитация отключения задачи

`docker service scale patroni_patroni3=0`

Включение задачи

`docker service scale patroni_patroni3=1`

Возможна ситуация, что нода будет работоспособна, но через haproxy она будет отображаться как недоступна в этом случае следует выполнить команду

`docker kill -s HUP haproxy-patroni`

5. Вход в консоль контейнера
`docker exec -it <id> /bin/bash`

6. Содержимое etcd можно посмотреть выполнив команду

`curl -s 'http://127.0.0.1:2379/v2/keys/service?recursive=true&sorted=true' | jq`

Или как альтернатива

`curl -s 'http://127.0.0.1:2379/v2/keys/?recursive=true&sorted=true' | jq`

Эту команду надо выполнить внутри контейнера etcd.

7.API patroni

Чтобы проверить статус кластера patroni, необходимо зайти в консоль контроллера haproxy

`docker exec -it <id> /bin/bash`

И командной строке выполнять запросы, которые вернуть JSON документ

`curl  http://patroniN:8091/patroni`

`curl  http://patroniN:8091/history`

`curl  http://patroniN:8091/cluster`

Если требуется проверить жизнеспособность узла, то необходимо выполнить запросы

`curl -i -X OPTIONS http://patroniN:8091/`

`curl -i -X OPTIONS http://patroniN:8091/master`

`curl -i -X OPTIONS http://patroniN:8091/leader`

`curl -i -X OPTIONS http://patroniN:8091/primary`

`curl -i -X OPTIONS http://patroniN:8091/read-write`

`curl -i -X OPTIONS http://patroniN:8091/replica`

`curl -i -X OPTIONS http://patroniN:8091/read-only`

`curl -i -X OPTIONS http://patroniN:8091/standby-leader`

`curl -i -X OPTIONS http://patroniN:8091/synchronous`

`curl -i -X OPTIONS http://patroniN:8091/asynchronous`

`curl -i -X OPTIONS http://patroniN:8091/health`

`curl -i -X OPTIONS http://patroniN:8091/liveness`

`curl -i -X OPTIONS http://patroniN:8091/readiness`

Пере инициализация, только не реплике

`curl -s http://patroni3:8091/reinitialize -XPOST -d  '{"force":true}'`

Аварийное переключение выполняем в контейнере haproxy

`curl -s http://patroni2:8091/failover -XPOST -d '{"candidate":"patroni1"}'`

Плановое переключение

`curl -s http://patroni2:8091/switchover -XPOST -d '{"leader":"patroni1"}'`

В случае когда из кластера выпали все узлы и включения первого узла, этот узел не может стать лидером необходимо выполнить очистку ключа в etcd выполнив команду, которая инициализирует кластер

`patronictl -c /etc/patroni.yml remove patroni`

echo -e "patroni\nYes I am aware" > /tmp/ddd
patronictl -c /etc/patroni.yml remove patroni < /tmp/ddd