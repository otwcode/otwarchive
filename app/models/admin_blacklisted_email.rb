class AdminBlacklistedEmail < ApplicationRecord
  before_validation :canonicalize_email
  after_create :remove_invite_requests

  validates :email, presence: true, uniqueness: { case_sensitive: false }, email_format: true

  def canonicalize_email
    self.email = EmailCanonicalizer.canonicalize(self.email) if self.email
  end

  def remove_invite_requests
    InviteRequest.where(simplified_email: self.email).destroy_all
  end

  # Check if an email is blacklisted
  def self.is_blacklisted?(email_to_check)
    AdminBlacklistedEmail.exists?(email: EmailCanonicalizer.canonicalize(email_to_check))
  end
end
