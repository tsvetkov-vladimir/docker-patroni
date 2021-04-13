#версия 2.2 является максимальной, версии 2.3 и 2.4 падают, не понятно почему
FROM haproxytech/haproxy-debian:2.2
COPY haproxy.cfg /usr/local/etc/haproxy/haproxy.cfg
RUN mkdir /run/haproxy \
    && apt-get update -y \
    && apt-get install -y hatop \
    && apt-get install -y tcpdump \
    && apt-get install -y iproute2 \
    && apt-get install -y iputils-ping \
    && apt-get install -y vim \
    && apt-get clean
