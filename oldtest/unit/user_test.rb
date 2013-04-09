require 'test_helper'

class UserTest < ActiveSupport::TestCase
  context "a user" do
    setup do
      assert create_user
    end
    should_validate_presence_of :login, :message => "Please enter a user name"
    should_validate_presence_of :email, :message => "Please enter an email address"
    should_validate_acceptance_of :age_over_13, :terms_of_service, :message => /Sorry/
    should_validate_uniqueness_of :login, :case_sensitive => false, :message => /already taken/
    should_validate_uniqueness_of :email, :case_sensitive => false, :message => /Sorry/
    should_ensure_length_in_range :login, (3..40), :short_message => /too short/, :long_message => /too long/
    should_ensure_length_in_range :email, (3..100), :short_message => /too short/, :long_message => /too long/
    should_have_many :pseuds, :readings, :inbox_comments
    should_have_one :profile, :preference
    should_not_allow_values_for :login, "_startswithunderscore", "endswithunderscore_", "with spaces", :message => /must/
    should_allow_values_for :login, "underscore_in_the_middle", "words1with2numbers", "ends123", "123start"
    should_not_allow_values_for :email, "noatsign", "user@badbadbad", :message => /valid address/
    should_allow_values_for :email, random_email
    
    context "using a password" do
      should_validate_presence_of :password, :message => /short/
      should_validate_presence_of :password_confirmation, :message => /again/
      should_ensure_length_in_range :password, (6..40), :short_message => /too short/, :long_message => /too long/
    end
  end
end
