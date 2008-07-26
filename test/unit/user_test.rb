require File.dirname(__FILE__) + '/../test_helper'

class UserTest < ActiveSupport::TestCase
  context "a user" do
    setup do
      assert create_user
    end
    should_require_attributes :login, :email
    should_require_attributes :age_over_13, :terms_of_service, :message => /must be accepted/
    should_require_unique_attributes :login, :email
    should_ensure_length_in_range :login, (3..40)
    should_ensure_length_in_range :email, (3..100)
    should_have_many :pseuds, :readings, :inbox_comments
    should_have_one :profile, :preference
    should_not_allow_values_for :login, "_startswithunderscore", "endswithunderscore_", "with spaces", :message => /must/
    should_allow_values_for :login, "underscore_in_the_middle", "words1with2numbers", "ends123", "123start"
    should_not_allow_values_for :email, "noatsign", "user@badbadbad", :message => /valid email/
    should_allow_values_for :email, random_email
    
    context "using a password" do
      should_require_attributes :password, :password_confirmation
      should_ensure_length_in_range :password, (6..40)
    end
    context "without a password" do
      setup do
        @url = random_url
        assert @user = create_user(:password => nil, :password_confirmation => nil, :identity_url => @url)
      end
      should "require an identity_url" do
        @user.identity_url=""
        assert !@user.valid?
        assert @user.errors.on("identity_url")
      end
      should "require a unique identity_url" do
        user2 = new_user(:password => nil, :password_confirmation => nil, :identity_url => @url)
        assert !user2.valid?
        assert user2.errors.on("identity_url")
      end
    end
  end
end
