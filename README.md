# docker-patroni

Пример установки и запуска patroni в среде Docker Swarm.

Предполагается, что установка выполняется на пустой машине с OS Debian 10.

Для тестирования и отладки использовались виртуальные машины созданные на ресурсе https://vscale.io.

## **Установка**

1.Устанавливаем git

`apt update`

`apt -y install git`

2. Клонируем репозиторий на каждый узел кластера

`git clone https://github.com/tsvetkov-vladimir/docker-patroni.git`

3. Устнавливаем docker и docker-compose на каждом узле кластера

`cd docker-patroni/`

`./install_docker.sh`

4.Проверка результата установки

`systemctl status docker`

`docker-compose --version`

## **Создание образов patroni и haproxy**

1.Выполняем команду на каждом узле

`./create_images.sh`

## **Запуск Docker swarm**

1.Выполняем команду на управляющем узле

`docker swarm init`

`docker node ls`

2.Для присоединения узла в качестве докера необходимо на присоединяемом узле выполнить команду

`docker swarm join --token SWMTKN-1-4nxtulbtj38n3v782satsnat3eu8lm7e74ir7u6i05nepjtwe6-c61idt643vdxrs7llpjkrvsl2 82.148.18.190:2377`

## **Запуск сервисов в кластере**

1.Выполняем команду на управляющем узле

`./deploy.sh`
