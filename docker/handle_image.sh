#!/bin/bash

set -e

version="$(cat ../src/version)"

another_tag="matejak/argbash:$version-${pkgrel:-1}"
another_tag_option=(-t "$another_tag")
dest="$version.tar.gz"

rm -f "$dest"
wget "https://github.com/matejak/argbash/archive/$version.tar.gz"
tar -xf "$dest"
mv "argbash-$version" argbash
docker build -f Dockerfile -t matejak/argbash:latest "${another_tag_option[@]}" .
rm -rf "argbash"
echo Now run:
echo docker login
echo docker push "$another_tag"
echo docker push matejak/argbash:latest
