# frozen_string_literal: true

class GeneratedDownload < ApplicationRecord
  EXPIRATION = 1.day
  STATUSES = %w[pending processing ready failed].freeze

  has_one_attached :file

  serialize :arguments, coder: JSON

  validates :token, :kind, :filename, :expires_at, presence: true
  validates :token, uniqueness: true
  validates :status, inclusion: { in: STATUSES }

  before_validation :set_defaults, on: :create

  def self.cleanup
    where(expires_at: ...Time.current).find_each do |download|
      download.file.purge if download.file.attached?
      download.destroy!
    end
  end

  def expired?
    expires_at.past?
  end

  private

  def set_defaults
    self.token ||= SecureRandom.urlsafe_base64(32)
    self.expires_at ||= EXPIRATION.from_now
  end
end
