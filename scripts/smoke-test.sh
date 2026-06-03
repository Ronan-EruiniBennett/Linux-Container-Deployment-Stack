#!/usr/bin/env bash

echo "Starting Container"

echo "Enter container name"
read NAME

echo "Enter computer port"
read PORT

sudo docker run -d --name $NAME -p $PORT:5000 -t infra-lab
 
if docker ps --format '{{.Names}}' | grep -q "^${NAME}$"; then
	echo "Container running"
else
	echo "Container is not running"
fi

 
