# frozen_string_literal: true
class Admin::PasswordsController < Devise::PasswordsController
  skip_before_action :store_location
  layout "session"
end
