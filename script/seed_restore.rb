#!/usr/bin/env script/runner
# usage:
# rake db:drop
# rake db:create
# rake db:schema:load
# rake db:migrate
# script/seed_restore.rb
# rake Tag:reset_filters
# rake Tag:reset_filter_counts
# script/create_admin.rb

backupdir = RAILS_ROOT + '/db/seed'
FileUtils.mkdir_p(backupdir)
FileUtils.chdir(backupdir)

puts "restoring Roles"
YAML.load_documents(File.read("roles_users.yml")) do |item|
  user = User.find_by_id(item["user_id"])
  role = Role.find_by_id(item["role_id"])
  user.roles << role if user
end

Dir.glob("*.yml").each do |file|
  klass = file.gsub('.yml', '').camelcase.constantize rescue nil
  puts "skipping #{file}" unless klass
  next unless klass
  puts "restoring #{klass}"
  klass.delete_observers
  klass.before_create.clear
  klass.after_create.clear
  klass.before_save.clear
  klass.after_save.clear
  YAML.load_documents(File.read(file)) do |item|
    unless klass.find_by_id(item["id"])
      if klass == Media
        new = klass.find_by_name(item["name"])
        new = klass.new(item) unless new
      else
        new = klass.new(item)
      end
      new.id = item["id"]
      new.save_with_validation(false)
      if klass == User || klass == Admin
        klass.before_update.clear
        item.each {|k,v| new.update_attribute(k, v)}
      end
    end
  end
end
