#!script/rails runner
# usage:
# RAILS_ENV=production script/create_admin.rb

print "Enter admin email: "
email = gets.chomp

print "Enter admin username: "
login = gets.chomp

print "Enter admin password: "
password = gets.chomp

a=Admin.new(email: email, login: login, password: password, password_confirmation: password)

if a.save
  print "Admin created\n"
else
  y a.errors.full_messages
end
