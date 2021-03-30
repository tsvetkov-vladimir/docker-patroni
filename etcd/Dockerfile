FROM bitnami/etcd:latest
USER root
RUN apt-get update -y\
     && apt-get install -y iproute2\
     && mkdir -p /bitnami/etcd/data\
     && chown -R etcd:etcd /bitnami/etcd/data\
     && chmod 0700 /bitnami/etcd/data