module Akismet
  # A wrapper around Akismetor that prevents the API from being called when in dev or test

  def self.spam?(akismet_attributes)
    return false if %w[staging production].exclude?(Rails.env)
    Akismetor.spam?(akismet_attributes)
  end
end