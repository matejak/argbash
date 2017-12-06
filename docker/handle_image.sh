#!/bin/bash

set -e

version="$(cat ../src/version)"
another_tag=(-t "matejak/argbash:$version")
dest="$version.tar.gz"

rm -f "$dest"
wget "https://github.com/matejak/argbash/archive/$version.tar.gz"
tar -xf "$dest"
mv "argbash-$version" argbash
docker build -f Dockerfile -t matejak/argbash:latest "${another_tag[@]}" .
rm -rf "argbash"
echo Now run:
echo docker login
echo docker push matejak/argbash:$version
echo docker push matejak/argbash:latest
