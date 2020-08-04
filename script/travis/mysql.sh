#!/bin/bash
set -e

# Use READ-COMMITTED transaction isolation level
# https://railsmachine.com/articles/2017/05/19/converting-a-rails-database-to-utf8mb4.html
sudo sed -i /etc/mysql/mariadb.conf.d/50-server.cnf  -e "s/\[mysqld\]/[mysqld]\n\
innodb_lock_wait_timeout=15\n\
transaction-isolation=READ-COMMITTED\n\
innodb_file_per_table=1\n\
/"

# The conf change requires a restart
sudo systemctl restart mariadb

sudo mysql -e "
CREATE USER 'travis'@'%' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON *.* TO 'travis'@'%';
flush privileges;"
