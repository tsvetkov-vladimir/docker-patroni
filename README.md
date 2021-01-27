# docker-patroni

Пример установки и запуска patroni в среде Docker Swarm.

Предполагается, что установка выполняется на пустой машине с OS Debian 10.

Для тестирования и отладки использовались виртуальные машины созданные на ресурсе https://vscale.io.

## **Установка**

1.Устанавливаем git

`apt update`

`apt -y install git`

2. Клонируем репозиторий

`git clone https://github.com/tsvetkov-vladimir/docker-patroni.git`

3. Устнавливаем docker и docker-compose

`cd docker-patroni/`

`chmod +x install_docker.sh`

`./install_docker.sh`

4.Проверка результата установки

`systemctl status docker`

`docker-compose --version`

## **Создание образов patroni и haproxy**