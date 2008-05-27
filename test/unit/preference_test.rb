require File.dirname(__FILE__) + '/../test_helper'

class PreferenceTest < ActiveSupport::TestCase
  # Test associations
  def test_belongs_to_user
    user = create_user
    pref = create_preference(:user_id => user.id)
    assert_equal user, pref.user
  end
end
