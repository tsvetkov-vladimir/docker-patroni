#!/bin/bash

while true
do
  psql postgresql://postgres:supass@127.0.0.1:5000/test -c "INSERT INTO test VALUES (DEFAULT)"
done