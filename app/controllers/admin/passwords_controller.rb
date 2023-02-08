# frozen_string_literal: true

class Admin::PasswordsController < Devise::PasswordsController
  before_action :user_logout_required, only: [:new, :edit]
  skip_before_action :store_location
  layout "session"
end
