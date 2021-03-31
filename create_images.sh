#!/bin/bash

cd etcd

docker build -t etcd .

cd ../patroni

docker build -t patroni .

cd ../haproxy

docker build -t haproxy-patroni .

docker image ls