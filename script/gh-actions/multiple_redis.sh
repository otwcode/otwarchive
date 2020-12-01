#!/bin/bash

mkdir -p redis
pushd redis

redis-server --daemonize yes --port 6379 --dbfilename "autocomplete.rdb" --pidfile "autocomplete.pid"
redis-server --daemonize yes --port 6380 --dbfilename "general.rdb" --pidfile "general.pid"
redis-server --daemonize yes --port 6381 --dbfilename "hits.rdb" --pidfile "hits.pid"
redis-server --daemonize yes --port 6382 --dbfilename "kudos.rdb" --pidfile "kudos.pid"
redis-server --daemonize yes --port 6383 --dbfilename "resque.rdb" --pidfile "resque.pid"
redis-server --daemonize yes --port 6384 --dbfilename "rollout.rdb" --pidfile "rollout.pid"

popd
