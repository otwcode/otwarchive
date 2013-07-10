require 'test_helper'

class AdminTest < ActiveSupport::TestCase
  # acts_as_authentable
  context "an admin" do
    setup do
      assert create_admin
    end
    should_validate_presence_of :login, :message => "Please enter a user name"
    should_validate_presence_of :email, :message => "Please enter an email address"
    should_validate_presence_of :password, :message => "Please enter a password"
    should_validate_presence_of :password_confirmation, :message => /again/
    should_ensure_length_in_range :password, (6..40), :short_message => /too short/, :long_message => /too long/
    should_ensure_length_in_range :login, (3..40), :short_message => /too short/, :long_message => /too long/
    should_ensure_length_in_range :email, (3..100), :short_message => /too short/, :long_message => /too long/
    should_validate_uniqueness_of :email, :case_sensitive => false, :message => /Sorry/
    should_validate_uniqueness_of :login, :case_sensitive => false, :message => /already taken/
  end
end
