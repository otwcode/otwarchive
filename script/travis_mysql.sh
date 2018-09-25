#!/bin/bash
set -e

# Use READ-COMMITTED transaction isolation level
sudo sed -i /etc/mysql/mysql.conf.d/mysqld.cnf  -e "s/\[mysqld\]/[mysqld]\ninnodb_lock_wait_timeout=15\ntransaction-isolation=READ-COMMITTED\n/"
cat /etc/mysql/mysql.conf.d/mysqld.cnf

# Fix table performance_schema.session_variables not existing
# https://stackoverflow.com/q/31967527
sudo mysql_upgrade --force

# Both the upgrade and the conf change require a restart
sudo service mysql restart

mysql -e "CREATE DATABASE otwarchive_test DEFAULT COLLATE utf8_unicode_ci DEFAULT CHARACTER SET utf8;"
