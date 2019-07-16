#!/bin/bash

args="$@"
command="composer $args"
echo "$command"
docker-compose exec larabook $command