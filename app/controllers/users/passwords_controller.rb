# Users namespace
module Users
  # Handle Devise password recovery
  class PasswordsController < Devise::PasswordsController
    before_filter :configure_reset_params, only: [:create]

    skip_after_filter :store_location

    layout 'session'

    private

    def configure_reset_params
      devise_parameter_sanitizer.for(:user) do |u|
        u.permit(:reset_password_for)
      end
    end
  end
end
