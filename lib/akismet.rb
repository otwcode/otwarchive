module Akismet
  # A wrapper around Akismetor that prevents the API from being called when in dev or test

  def self.spam?(akismet_attributes)
    return false if %w[staging production].exclude?(Rails.env)
    Akismetor.spam?(akismet_attributes)
  end

  def self.submit_spam(akismet_attributes)
    # don't submit spam reports unless in production mode
    Rails.env.production? && Akismetor.submit_spam(akismet_attributes)
  end

  def self.submit_ham(akismet_attributes)
    # don't submit ham reports unless in production mode
    Rails.env.production? && Akismetor.submit_ham(akismet_attributes)
  end
end
