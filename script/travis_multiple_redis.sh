#!/bin/bash
echo "cat /etc/redis/redis.conf | sed -e s'#pidfile  /var/run/redis/redis.pid# /var/run/redis/redis.pid2#' -e 's/port 6379/port 6380/' -e 's/dbfilename redis.rdb/dbfilename redis2.rdb/' >  /etc/redis/redis2.conf" | sudo sh
echo "cat /etc/redis/redis.conf | sed -e s'#pidfile  /var/run/redis/redis.pid# /var/run/redis/redis.pid3#' -e 's/port 6379/port 6381/' -e 's/dbfilename redis.rdb/dbfilename redis3.rdb/' >  /etc/redis/redis3.conf" | sudo sh
echo "cat /etc/redis/redis.conf | sed -e s'#pidfile  /var/run/redis/redis.pid# /var/run/redis/redis.pid4#' -e 's/port 6379/port 6382/' -e 's/dbfilename redis.rdb/dbfilename redis4.rdb/' >  /etc/redis/redis4.conf" | sudo sh
echo "cat /etc/redis/redis.conf | sed -e s'#pidfile  /var/run/redis/redis.pid# /var/run/redis/redis.pid6#' -e 's/port 6379/port 6383/' -e 's/dbfilename redis.rdb/dbfilename redis5.rdb/' >  /etc/redis/redis5.conf" | sudo sh
echo "cat /etc/redis/redis.conf | sed -e s'#pidfile  /var/run/redis/redis.pid# /var/run/redis/redis.pid7#' -e 's/port 6379/port 6384/' -e 's/dbfilename redis.rdb/dbfilename redis6.rdb/' >  /etc/redis/redis6.conf" | sudo sh
echo "/usr/bin/redis-server  /etc/redis/redis2.conf" | sudo sh
echo "/usr/bin/redis-server  /etc/redis/redis3.conf" | sudo sh
echo "/usr/bin/redis-server  /etc/redis/redis4.conf" | sudo sh
echo "/usr/bin/redis-server  /etc/redis/redis5.conf" | sudo sh
echo "/usr/bin/redis-server  /etc/redis/redis6.conf" | sudo sh
