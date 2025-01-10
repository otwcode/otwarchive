# frozen_string_literal: true

class ArchiveDeviseMailerPreview < ApplicationMailerPreview
  # Sent when a user requests a password reset
  def reset_password_instructions
    user = create(:user, :for_mailer_preview)
    ArchiveDeviseMailer.reset_password_instructions(user, "fakeToken")
  end
end
