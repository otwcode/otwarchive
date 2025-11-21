# Run this script and follow the onscreen instructions:
#   bundle exec rails r script/send_backup_codes_to_admin.rb

puts <<~PROMPT
  Enter the login of the admin to generate and send recovery codes to:
PROMPT

login = gets.chomp

login = login.strip
admin = Admin.find_by(login: login)

unless admin
  puts "Admin not found."
  return
end

unless admin.otp_required_for_login
  puts "This admin does not have TOTP two-factor authentication enabled."
  return
end

codes = admin.generate_otp_backup_codes!
admin.save!

AdminMailer.totp_2fa_backup_codes(admin, codes).deliver

puts "Backup codes successfully sent to the admin."
