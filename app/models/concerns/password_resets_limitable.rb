module PasswordResetsLimitable
  extend ActiveSupport::Concern

  included do
    def password_resets_limit_reached?
      self.resets_requested >= ArchiveConfig.PASSWORD_RESET_LIMIT && self.last_reset_within_cooldown?
    end

    def password_resets_available_time
      self.reset_password_sent_at + ArchiveConfig.PASSWORD_RESET_COOLDOWN_HOURS.hours
    end

    def update_password_resets_requested
      if self.resets_requested.positive? && !self.last_reset_within_cooldown?
        self.resets_requested = 1
      else
        self.resets_requested += 1
      end
    end
  end

  private

  def last_reset_within_cooldown?
    self.reset_password_sent_at.nil? ||
      self.reset_password_sent_at > ArchiveConfig.PASSWORD_RESET_COOLDOWN_HOURS.hours.ago
  end
end
