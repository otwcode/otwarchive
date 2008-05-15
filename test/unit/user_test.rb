require File.dirname(__FILE__) + '/../test_helper'

class UserTest < ActiveSupport::TestCase

  def test_has_pseud_with_pseudnames_user_has
    user = users(:basic_user)
    assert user.has_pseud?("basic_user")
    assert user.has_pseud?("Non-Default Pseud")
  end

  def test_has_pseud_with_pseudnames_user_doesnt_have
    user = users(:basic_user)
    assert !user.has_pseud?("Default")
    assert !user.has_pseud?("Not one of his pseuds")
    assert !user.has_pseud?("Foo")
  end

  def test_has_pseud_with_crazy_arguments
    user = users(:basic_user)
    pseud = pseuds(:default_pseud)
    assert !user.has_pseud?(pseud)
    assert !user.has_pseud?("")
    assert !user.has_pseud?(nil)
  end

  def test_default_pseud
    user = users(:basic_user)
    default_pseud = pseuds(:default_pseud)
    assert_equal default_pseud, user.default_pseud
  end

  def test_creations_for_user_with_creations
    user = users(:basic_user)
    no_of_creations = 12
    assert_equal no_of_creations, user.creations.length
  end

  def test_creations_for_user_without_creations
    user = users(:user_with_one_pseud)
    no_of_creations = 0
    assert_equal no_of_creations, user.creations.length
  end

end
