class AdminBlacklistedEmail < ApplicationRecord
  before_validation :canonicalize_email
  after_create :remove_invite_requests

  validates :email, presence: true, uniqueness: { case_sensitive: false }, email_format: true

  def canonicalize_email
    self.email = AdminBlacklistedEmail.canonical_email(self.email) if self.email
  end

  def remove_invite_requests
    InviteRequest.where(simplified_email: self.email).destroy_all
  end

  # Produces a canonical version of a given email reduced to its simplest form
  # This is what we store in the db, so that if we subsequently check a submitted email,
  #  we only need to clean the submitted email the same way and look for it.
  def self.canonical_email(email_to_clean)
    canonical_email = email_to_clean.downcase
    canonical_email.strip!
    canonical_email.sub!('@googlemail.com','@gmail.com')

    # strip periods from gmail addresses
    if (matchdata = canonical_email.match(/(.+)\@gmail\.com/))
      canonical_email = matchdata[1].gsub('.', '') + "@gmail.com"
    end

    # strip out anything after a +
    canonical_email.sub!(/(\+.*)(@.*$)/, '\2')

    return canonical_email
  end

  # Check if an email is
  def self.is_blacklisted?(email_to_check)
    AdminBlacklistedEmail.exists?(email: AdminBlacklistedEmail.canonical_email(email_to_check))
  end
end
