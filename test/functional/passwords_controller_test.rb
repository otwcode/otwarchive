require 'test_helper'

class PasswordsControllerTest < ActionController::TestCase
# FIXME routes.rb - routes exist but have no action
  # Test create  POST  /:locale/passwords
  def test_create_password_reset
    user = create_user
    user.activate
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
    before = user.crypted_password
    post :create, :locale => 'en', :login => user.login
    after = User.find(user.id).crypted_password

    assert_not_equal after, before
    assert_equal(1, ActionMailer::Base.deliveries.length)
    assert flash.has_key?(:notice)
    assert_template "new"
    assert_response :success
  end
  def test_create_password_reset_fail
    post :create, :locale => 'en', :login => "no such user"
    assert flash.has_key?(:login)
    assert_template "new"
    assert_response :success
  end
  # Test destroy  DELETE /:locale/passwords/:id
  # Test edit  GET  /:locale/passwords/:id/edit  (named path: edit_password)
  # Test index  GET  /:locale/passwords  (named path: passwords)
  # Test new  GET  /:locale/passwords/new  (named path: new_password)
  def test_new_password_path
    get :new, :locale => 'en'
    assert_response :success
  end
  # Test show  GET  /:locale/passwords/:id  (named path: password)
  # Test update  PUT  /:locale/passwords/:id
end
