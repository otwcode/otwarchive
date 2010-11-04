#!/usr/bin/env rails script/runner

# usage:
=begin
RAILS_ENV=production rake db:schema:dump
rake db:schema:load
rails runner script/seed_restore.rb
rake Tag:reset_filters
rake Tag:reset_filter_counts
rails runner script/create_admin.rb
=end

BACKUPDIR = Rails.root.to_s + '/db/seed'

# change into directory so filenames don't have path information
FileUtils.chdir(BACKUPDIR)

# grab up all the sql files and process
Dir.glob("*.sql").each do |file|
  klass = file.gsub('.sql', '').classify
  puts "restoring #{klass}"
  File.readlines(file).each do |line|
    begin
      ActiveRecord::Base.connection.execute(line.chomp)
    rescue ActiveRecord::RecordNotUnique
      # in case you dumped something twice
    end
  end
end
