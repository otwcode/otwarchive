#!/bin/bash

echo "cat /etc/redis/redis.conf | sed -e 's/.pid$/2.pid/' -e 's/^port 6379/port 6380/' -e 's/.rdb$/2.rdb/' > /etc/redis/redis2.conf" | sudo sh
echo "cat /etc/redis/redis.conf | sed -e 's/.pid$/3.pid/' -e 's/^port 6379/port 6381/' -e 's/.rdb$/3.rdb/' > /etc/redis/redis3.conf" | sudo sh
echo "cat /etc/redis/redis.conf | sed -e 's/.pid$/4.pid/' -e 's/^port 6379/port 6382/' -e 's/.rdb$/4.rdb/' > /etc/redis/redis4.conf" | sudo sh
echo "cat /etc/redis/redis.conf | sed -e 's/.pid$/5.pid/' -e 's/^port 6379/port 6383/' -e 's/.rdb$/5.rdb/' > /etc/redis/redis5.conf" | sudo sh
echo "cat /etc/redis/redis.conf | sed -e 's/.pid$/6.pid/' -e 's/^port 6379/port 6384/' -e 's/.rdb$/6.rdb/' > /etc/redis/redis6.conf" | sudo sh

# Spot the differences!
sudo diff /etc/redis/redis.conf /etc/redis/redis2.conf

# Start 5 more instances of Redis.
sudo redis-server /etc/redis/redis2.conf
sudo redis-server /etc/redis/redis3.conf
sudo redis-server /etc/redis/redis4.conf
sudo redis-server /etc/redis/redis5.conf
sudo redis-server /etc/redis/redis6.conf
