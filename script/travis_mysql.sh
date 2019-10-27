#!/bin/bash
set -e

# 1. Use READ-COMMITTED transaction isolation level
# 2. Use the Barracuda file format for longer index key prefixes
#    https://railsmachine.com/articles/2017/05/19/converting-a-rails-database-to-utf8mb4.html
sudo sed -i /etc/mysql/mysql.conf.d/mysqld.cnf  -e "s/\[mysqld\]/[mysqld]\n\
innodb_lock_wait_timeout=15\n\
transaction-isolation=READ-COMMITTED\n\
innodb_file_format=Barracuda\n\
innodb_large_prefix\n\
innodb_file_per_table=1\n\
/"
cat /etc/mysql/mysql.conf.d/mysqld.cnf

# The conf change requires a restart
sudo service mysql restart

mysql -e "CREATE DATABASE otwarchive_test DEFAULT COLLATE utf8mb4_unicode_ci DEFAULT CHARACTER SET utf8mb4;"
