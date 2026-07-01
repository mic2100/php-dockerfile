#!/usr/bin/env zsh

git checkout 8.4
docker build -t mic2100/php-fpm:8.4 .
docker push mic2100/php-fpm:8.4

git checkout 8.5
docker build -t mic2100/php-fpm:8.5 .
docker push mic2100/php-fpm:8.5

git checkout master
