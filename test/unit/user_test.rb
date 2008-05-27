require File.dirname(__FILE__) + '/../test_helper'

class UserTest < ActiveSupport::TestCase
  # Test accessors
    # TODO test accessors
  # Test validations
    # TODO validates_associated pseuds, profile, preference
    # TODO validates_format_of_login
    # TODO validates_email_veracity_of
    # TODO validates_inclusion_of terms_of_service, age_over_13
  
  # Test assocations
    # TODO has_many :pseuds, works, readings
    # TODO has_one :profile, preference
  
  # Test acts_as
    # TODO  acts_as_authentable
    # TODO  acts_as_authorized_user
    # TODO  acts_as_authorizable

  # Test before and after
    # TODO create_default_associateds
  
  # Test methods
  def test_has_pseud
    user = create_user
    assert user.has_pseud?(user.login)
    newname = random_phrase
    create_pseud(:user => user, :name => newname)
    assert User.find(user.id).has_pseud?(newname)
    assert !user.has_pseud?(random_phrase)
    assert !user.has_pseud?("")
    assert !user.has_pseud?(nil)
  end
  def test_default_pseud
    user = create_user
    assert default = user.default_pseud
    assert_equal default.name, user.login
    pseud = create_pseud(:user => user)
    assert_not_equal user.default_pseud, pseud
    # FIXME no error checking on is_default - can have two or none
    default.is_default = false  
    default.save
    pseud.is_default = true
    pseud.save
    assert_equal User.find(user.id).default_pseud, pseud
  end
  def test_creations
    user = create_user
    assert_equal 0, user.creations.length
    work = create_work(:authors => [user.default_pseud])
    assert_equal 2, user.creations.length
    create_chapter(:work_id => work.id, :authors =>[user.default_pseud])
    assert_equal 3, user.creations.length  
    pseud = create_pseud(:user => user)
    create_work(:authors => [pseud])
    assert_equal 5, User.find(user.id).creations.length
  end
  
end
