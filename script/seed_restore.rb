#!/usr/bin/env rails script/runner

# usage:
=begin
git fetch
git fetch --tags
git reset --hard `git tag | tail -1`
RAILS_ENV=production bundle exec rake db:schema:dump
bundle exec rake db:drop
bundle exec rake db:create
bundle exec rake db:schema:load
bundle exec rails runner script/seed_restore.rb
bundle exec rake Tag:reset_filters
bundle exec rake Tag:reset_filter_counts
bundle exec rake skins:load_site_skins
bundle exec rails runner script/create_admin.rb
# mysqldump seed_development > ~/seed.dump 
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
    rescue Encoding::CompatibilityError
      puts "The following line had an encoding error. Add manually."
      puts line
    end
  end
end
