#!/bin/bash
find /etc/mysql* -ls
sed -i  /etc/mysql/my.cnf  -e 's/\[mysqld\]/[mysqld]\ninnodb_lock_wait_timeout=15\ntransaction-isolation = READ-COMMITTED\n/'
systemctl restart mysql
