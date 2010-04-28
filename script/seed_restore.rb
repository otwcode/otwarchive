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
  Media.delete_all if klass == Media
  YAML.load_documents(File.read(file)) do |item|
    unless klass.find_by_id(item["id"])
      new = klass.new(item)
      new.id = item["id"]
      new.save_with_validation(false)
      # Users and Admins don't save crypted_password or salt on create
      if klass == User || klass == Admin
        klass.before_update.clear
        new.update_attribute(:crypted_password, item["crypted_password"])
        new.update_attribute(:salt, item["salt"])
      end
    end
  end
end

puts "restoring Role associations"
YAML.load_documents(File.read("roles_users.yml")) do |item|
  user = User.find_by_id(item["user_id"])
  role = Role.find_by_id(item["role_id"])
  user.roles << role if user
end

