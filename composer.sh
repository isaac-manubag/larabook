#!/bin/bash

args="$@"
command="composer $args"
echo "$command"
docker-compose exec larabook bash -c "cd /var/www/html && $command"