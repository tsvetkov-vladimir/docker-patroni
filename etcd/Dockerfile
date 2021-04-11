FROM bitnami/etcd:latest
USER root
RUN apt-get update -y \
     && apt-get install -y iproute2 \
     && apt-get install -y iputils-ping \
     && apt-get install -y curl \
     && mkdir -p /bitnami/etcd/data \
     && useradd etcd \
     && chown -R etcd:etcd /bitnami/etcd/data \
     && chmod 0700 /bitnami/etcd/data