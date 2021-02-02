FROM haproxytech/haproxy-debian:2.2
COPY haproxy.cfg /usr/local/etc/haproxy/haproxy.cfg
RUN mkdir /run/haproxy &&\
    apt-get update -y &&\
    apt-get install -y hatop &&\
    apt-get clean
