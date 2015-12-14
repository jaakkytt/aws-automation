#!/usr/bin/env bash
set -o errexit

mkdir -p /var/www/nginx-default
echo "Hello!" > /var/www/nginx-default/index.html
chmod 0644 /var/www/nginx-default/index.html
