require 'test_helper'

class RoleTest < Test::Unit::TestCase
  # Test associations
  def test_habtm_users
    user = create_user
    role = create_role
    assert role.users << user
    assert_contains(user.roles, role)
  end
  # TODO belongs_to :authorizable
end
