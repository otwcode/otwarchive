# Be sure to restart your server when you modify this file.

# Configure parameters to be partially matched (e.g. passw matches password) and filtered from the log file.
# Use this to limit dissemination of sensitive information.
# See the ActiveSupport::ParameterFilter documentation for supported notations and behaviors.
Rails.application.config.filter_parameters += [
  :passw, :email, :secret, :token, :_key, :crypt, :salt, :certificate, :otp, :ssn, :cvv, :cvc,
  :content, :terms_of_service_non_production
]

# IMPORTANT! Rails.application.config.filter_parameters must be set *above* in this file
# Ensure filter_attributes is always set. Without this, it is brittle.
# See https://github.com/rails/rails/issues/48704
ActiveRecord::Base.filter_attributes += Rails.application.config.filter_parameters
