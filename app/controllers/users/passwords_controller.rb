# frozen_string_literal: true

# Use for resetting lost passwords
class Users::PasswordsController < Devise::PasswordsController
  skip_before_action :store_location
  layout "session"

  def create
    super do |user|
      if user.nil? || user.new_record?
        flash.now[:notice] = ts("We couldn't find an account with that email address or username. Please try again?")
      end
    end
  end
end
