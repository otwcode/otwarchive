module PasswordResetsLimitable
  extend ActiveSupport::Concern

  included do
    def password_resets_remaining
      return ArchiveConfig.PASSWORD_RESET_LIMIT unless self.last_reset_within_cooldown?

      limit_delta = ArchiveConfig.PASSWORD_RESET_LIMIT - self.resets_requested
      limit_delta.positive? ? limit_delta : 0
    end

    def password_resets_limit_reached?
      password_resets_remaining < 1
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

    protected

    def clear_reset_password_token
      super
      self.resets_requested = 0
    end
  end

  private

  def last_reset_within_cooldown?
    self.reset_password_sent_at.present? &&
      self.reset_password_sent_at > ArchiveConfig.PASSWORD_RESET_COOLDOWN_HOURS.hours.ago
  end
end
