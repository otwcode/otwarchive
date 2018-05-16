#!/bin/bash
find /etc/mysql* -ls
sed -i  /etc/mysql/my.cnf  -e 's/\[mysqld\]/[mysql]\ninnodb_lock_wait_timeout=15\ntransaction-isolation = READ-COMMIT TED\n/'

cat /etc/mysql/my.cnf