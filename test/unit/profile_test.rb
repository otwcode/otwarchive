require File.dirname(__FILE__) + '/../test_helper'

class ProfileTest < ActiveSupport::TestCase
  # Test associations
  def test_belongs_to_user
    user = create_user
    profile = create_profile(:user_id => user.id)
    assert_equal user, profile.user
  end
end
