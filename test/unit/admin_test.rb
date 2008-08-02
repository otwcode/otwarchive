require File.dirname(__FILE__) + '/../test_helper'

class AdminTest < ActiveSupport::TestCase
  # acts_as_authentable
  context "an admin" do
    setup do
      @admin = create_admin
    end
    should_require_attributes :login, :message => "Please enter a user name"
    should_require_attributes :email, :message => "Please enter an email address"
    should_require_attributes :password, :message => "Please enter a password"
    should_require_attributes :password_confirmation, :message => /again/
    should_ensure_length_in_range :password, (6..40)
    should_ensure_length_in_range :login, (3..40)
    should_ensure_length_in_range :email, (3..100)
    should_require_unique_attributes :email, :message => /Sorry/
    should_require_unique_attributes :login
  end
end
