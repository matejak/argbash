#!/bin/bash

another_tag=(${1+-t "$1"})

docker login
docker build -f docker/Dockerfile -t matejak/argbash:latest "${another_tag[@]}"
docker push matejak/argbash:latest
