require File.dirname(__FILE__) + '/../test_helper'

class AdminTest < ActiveSupport::TestCase
  # acts_as_authentable
  context "an admin" do
    setup do
      @admin = create_admin
    end
    should_require_attributes :login, :email, :password, :password_confirmation
    should_ensure_length_in_range :password, (6..40)
    should_ensure_length_in_range :login, (3..40)
    should_ensure_length_in_range :email, (3..100)
    should_require_unique_attributes :login, :email
  end
end
