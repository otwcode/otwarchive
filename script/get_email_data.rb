#!script/rails runner
# usage:
# bundle exec rails r script/get_email_data.rb

print "Enter email: "
email = gets.chomp

puts EmailDataReport.new(email)
