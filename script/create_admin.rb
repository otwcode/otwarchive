#!script/rails runner
# 
# 1. Run this script on production as follows:
#      RAILS_ENV=production bundle exec rails r script/create_admin.rb
# 2. When prompted, type or paste in the admins, one per line, in the format USERNAME, EMAIL 
#    (USERNAME is Org name without the admin- prefix or any spaces)
# 3. Enter a final blank line to finish inputting admins
# 4. Follow the onscreen instructions

require 'csv'

def multi_gets(all_text = '')
  until (text = gets) == "\n"
    all_text << text
  end
  all_text.chomp
end

print "Paste or enter admins, one per line, in the format\n\tUSERNAME, EMAIL\n
(where USERNAME is their Org name without spaces and without the admin- prefix)\n
then two line breaks to end:\n"
input = multi_gets

list = CSV.parse(input)

puts "\nCopy and paste each section into a separate file and upload to the user's Vault:\n"

admins = []
list.each do |user|
  name = user[0].strip
  email = user[1].strip
  password = `pwgen 8 1`.strip

  a = Admin.new(email: email, login: "admin-#{name}", password: password, password_confirmation: password)

  if a.save
    puts
    puts "username: admin-#{name}"
    puts "password: #{password}"
    puts "http://archiveofourown.org/admin/login"
    puts
    admins << a
  else
    puts a.errors.full_messages
  end
end

puts "\nCopy and paste into the wiki at https://wiki.transformativeworks.org/mediawiki/AO3_Admins:\n"

admins.each do |admin|
  puts "|-\n| #{Date.today.to_formatted_s("YYYY-MM-dd")} || #{admin.login} || UPDATE WITH USER COMMITTEE"
end
