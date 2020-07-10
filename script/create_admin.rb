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

print "Paste or enter admins, one per line, in the format

\tUSERNAME, EMAIL, ROLE
or
\tUSERNAME, EMAIL, ROLE, ROLE, ROLE

where USERNAME is their Org name without spaces and without the admin- prefix
and ROLE is one of:

#{Admin::VALID_ROLES.sort.map { |r| "\t#{r}" }.join("\n")}

then two line breaks to end:\n\n"
input = multi_gets

list = CSV.parse(input)

puts "\nCopy and paste each section into a separate file and upload to the user's Vault:\n"

admins = []
list.each do |user|
  name = user[0].gsub(/\s+/, "")
  email = user[1].strip
  password = `pwgen 8 1`.strip
  roles = user.drop(2).compact.map(&:strip)

  a = Admin.new(
    email: email,
    login: "admin-#{name}",
    password: password,
    password_confirmation: password,
    roles: roles
  )

  if a.save
    puts
    puts "username: #{a.login}"
    puts "password: #{password}"
    puts new_admin_session_url
    puts
    admins << a
  else
    puts a.errors.full_messages
  end
end

puts "\nCopy and paste into the wiki at https://wiki.transformativeworks.org/mediawiki/AO3_Admins:\n"

admins.each do |admin|
  role_description = admin.roles.map { |r| I18n.t("activerecord.attributes.admin/role.#{r}") }.sort.join(", ")
  role_description = "UPDATE WITH USER COMMITTEE" if role_description.blank?
  puts "|-\n| #{Time.zone.today.to_formatted_s('YYYY-MM-dd')} || #{admin.login} || #{role_description}"
end
