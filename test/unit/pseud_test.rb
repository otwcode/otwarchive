require File.dirname(__FILE__) + '/../test_helper'

class PseudTest < ActiveSupport::TestCase
  # Test validations
  def test_presence_of_name
    pseud = new_pseud(:name => '')
    assert !pseud.save
    pseud.name = random_phrase
    assert pseud.save
  end
  # Test associations
  def test_belongs_to_user
    user = create_user
    pseud = create_pseud(:user => user)
    assert_equal user, pseud.user
  end
   # TODO has_many_polymorphs :creations,   has_many :comments
  # Test acts_as
   #TODO   acts_as_commentable
  # Test methods
    # TODO test_user_name
    # TODO test_add_creations
    # TODO test_remove_creation
    # TODO test_move_creations_to_default
end
