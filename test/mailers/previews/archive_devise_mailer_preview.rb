# frozen_string_literal: true

class ArchiveDeviseMailerPreview < ApplicationMailerPreview
  # Sent when a user requests a password reset
  def reset_password_instructions
    user = create(:user, :for_mailer_preview)
    ArchiveDeviseMailer.reset_password_instructions(user, "fakeToken")
  end

  # URL: /rails/mailers/archive_devise_mailer/confirmation_instructions?confirmation_sent_at=2025-01-23T20:00
  def confirmation_instructions
    user = create(:user, :for_mailer_preview, confirmation_sent_at: (params[:confirmation_sent_at] ? params[:confirmation_sent_at].to_time : Time.current))
    ArchiveDeviseMailer.confirmation_instructions(user, "fakeToken")
  end

  # URL: /rails/mailers/archive_devise_mailer/password_change_user
  def password_change_user
    user = create(:user, :for_mailer_preview)
    ArchiveDeviseMailer.password_change(user)
  end

  # URL: /rails/mailers/archive_devise_mailer/password_change_admin
  def password_change_admin
    admin = create(:admin, login: "admin-#{Faker::Alphanumeric.alpha(number: 8)}")
    ArchiveDeviseMailer.password_change(admin)
  end
end
