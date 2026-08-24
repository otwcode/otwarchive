#!script/rails runner
# usage:
# bundle exec rails r script/get_email_data.rb

print "Enter email: "
email = gets.chomp

print "Search audits for deleted accounts? This scans the whole audits table and should only be run at low-traffic times. (y/N): "
deep_search = gets.chomp.strip.casecmp?("y")

puts EmailDataReport.new(email, deep_search: deep_search)
