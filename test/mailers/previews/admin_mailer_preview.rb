class AdminMailerPreview < ApplicationMailerPreview
  def totp_2fa_backup_codes
    admin = create(:admin)
    codes = admin.generate_otp_backup_codes!
    AdminMailer.totp_2fa_backup_codes(admin, codes)
  end
end
