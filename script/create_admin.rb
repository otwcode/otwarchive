#!script/rails runner
#
# Run this script and follow the onscreen instructions:
#   bundle exec rails r script/create_admin.rb

require "csv"

include Rails.application.routes.url_helpers

# Base URL
default_url_options[:host] = ArchiveConfig.APP_URL

def multi_gets(all_text = "")
  until (text = gets) == "\n"
    all_text << text
  end
  all_text.chomp
end

puts <<~PROMPT
  Paste or enter admins, one per line, in the format

    USERNAME, EMAIL, ROLE

  or

    USERNAME, EMAIL, ROLE, ROLE, ROLE

  where

  - USERNAME is their OTW name without the admin- prefix (spaces will be removed)
  - EMAIL/ROLE can be left blank to skip updating email/roles of existing admins
  - ROLE is one of:

  #{Admin::VALID_ROLES.sort.map { |r| "  #{r}" }.join("\n")}

  then two line breaks to end:

PROMPT

list = CSV.parse(multi_gets)

puts "\nFor new admins, copy and paste each section into a separate file and upload to the admin's Vault:\n"

admins = []
list.each do |user|
  login = user[0].gsub(/\s+/, "")
  email = user[1]&.strip
  roles = user.drop(2).compact.map(&:strip).map(&:downcase)

  a = Admin.find_or_initialize_by(login: "admin-#{login}")
  a.email = email if email.present?
  a.roles = roles if roles.present?

  if a.new_record?
    # Create password only for new admins
    password = `pwgen 8 1`.strip
    a.password = password
    a.password_confirmation = password

    password_file = <<~PASSFILE
      username: #{a.login}
      password: #{password}
      #{new_admin_session_url}
    PASSFILE
  end

  puts "==== #{a.login}.txt"
  if a.save
    puts password_file if password_file.present?
    admins << a
  else
    puts a.errors.full_messages
  end
  puts
end

puts "\nFor all saved admins, copy and paste into the wiki at https://wiki.transformativeworks.org/mediawiki/AO3_Admins:\n"

admins.sort_by!(&:created_at)
admins.each do |admin|
  role_description = admin.roles.map { |r| I18n.t("activerecord.attributes.admin/role.#{r}") }.sort.join(", ")
  role_description = "UPDATE WITH USER COMMITTEE" if role_description.blank?
  puts "|-\n| #{admin.created_at.strftime('%Y-%m-%d')} || #{admin.login} || #{role_description}"
end
