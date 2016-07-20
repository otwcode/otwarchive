# User namespace and class.
# Class methods related to password reset are stored here
class User
  # Handle Devise password recovery
  class PasswordsController < Devise::PasswordsController
    before_filter :configure_reset_params, only: [:create]

    skip_after_filter :store_location

    layout 'session'

    def after_resetting_password_path_for(resource)
      super(resource)
    end

    private

    def configure_reset_params
      devise_parameter_sanitizer.for(:user) do |u|
        u.permit(:reset_password_for)
      end
    end
  end

  # Overwrite Devise reset password method so we can
  # search for both user login or email.
  def self.send_reset_password_instructions(attributes = {})
    reset = attributes[:reset_password_for]
    key = reset.include?('@') ? :email : :login
    attributes[key] = reset

    # The "trick" here is to define a key and force Devise to search our user
    # based on that key, that could be either :login or :email
    recoverable = find_or_initialize_with_errors([key], attributes)
    recoverable.send_reset_password_instructions if recoverable.persisted?

    # No matter what Devise return us, we define a default error message
    unless recoverable.errors.empty?
      recoverable.errors.clear
      recoverable.errors.add(:base, :not_found, message: ts("We couldn't find an account with that email address or username. Please try again?"))
    end

    recoverable
  end
end
