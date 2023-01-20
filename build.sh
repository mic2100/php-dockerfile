#!/usr/bin/env zsh

git checkout 7.4.33
docker build -t mic2100/php-fpm:7.4 .
docker push mic2100/php-fpm:7.4

git checkout 8.0.25
docker build -t mic2100/php-fpm:8.0 .
docker push mic2100/php-fpm:8.0

git checkout 8.1.12
docker build -t mic2100/php-fpm:8.1 .
docker push mic2100/php-fpm:8.1

git checkout 8.2
docker build -t mic2100/php-fpm:8.2 .
docker push mic2100/php-fpm:8.2

git checkout master
