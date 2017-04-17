class ActiveRecord::ConnectionAdapters::Mysql2Adapter
  # http://stackoverflow.com/questions/9376610/bigint-mysql-performance-compared-to-int
  # http://stackoverflow.com/questions/33755062/mysql-5-7-9-rails-3-2-mysql2-0-3-20
  NATIVE_DATABASE_TYPES[:primary_key] = "INT(11) auto_increment PRIMARY KEY"
end
