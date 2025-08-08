# Be sure to restart your server when you modify this file.

# Configure parameters to be partially matched (e.g. passw matches password) and filtered from the log file.
# Use this to limit dissemination of sensitive information.
# See the ActiveSupport::ParameterFilter documentation for supported notations and behaviors.
Rails.application.config.filter_parameters += [
  :passw, :email, :secret, :token, :_key, :crypt, :salt, :certificate, :otp, :ssn
]

# WARNING: Due to https://github.com/rails/rails/issues/48704, the filter parameters defined here do not get applied to
# ActiveRecord::Base.filter_attributes. Set any important filter parameters that should be applied to active record
# in application.rb instead.
