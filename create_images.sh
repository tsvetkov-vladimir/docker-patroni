#!/bin/bash

cd patroni

docker build -t patroni .

cd ../haproxy

docker build -t haproxy-patroni .