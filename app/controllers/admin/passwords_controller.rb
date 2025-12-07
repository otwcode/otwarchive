# frozen_string_literal: true

class Admin::PasswordsController < Devise::PasswordsController
  before_action :user_logout_required
  layout "session"
end
