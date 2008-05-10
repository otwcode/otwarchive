require File.dirname(__FILE__) + '/../test_helper'

class PasswordsControllerTest < ActionController::TestCase
  fixtures :users
  def test_should_get_new
    get :new, :locale => 'en'
    assert_response :success
  end
  def test_reset_password
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
    before = User.find(:first).crypted_password
    post :create, :locale => 'en', :login => User.find(:first).login
    after = User.find(:first).crypted_password

    assert_not_equal after, before
    assert_equal(1, ActionMailer::Base.deliveries.length)
    assert flash.has_key?(:notice)
    assert_redirected_to login_path
  end
  def test_didnt_reset   # no such user
    post :create, :locale => 'en', :login => "no such user"
    assert flash.has_key?(:error)
    assert_template "new"
    assert_response :success
  end
end
