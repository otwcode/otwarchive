require File.dirname(__FILE__) + '/../test_helper'

class UsersControllerTest < ActionController::TestCase
  def test_should_get_new
    get :new, :locale => 'en'
    assert_response :success
  end

  def test_should_create_user
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
    
    assert_difference('User.count') do
      post :create, :locale => 'en', :user => { :login => 'test_create', 
                                                :email => 'test_create@example.com', 
                                                :password => 'foobar', 
                                                :password_confirmation => 'foobar',
                                                :age_over_13 => '1',
                                                :terms_of_service => '1',
                                                }
    end

    assert_response :success
    assert_equal(1, ActionMailer::Base.deliveries.length)
  end

  def test_should_show_user
    get :show, :locale => 'en', :id => users(:basic_user).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :locale => 'en', :id => users(:basic_user).id
    assert_response :success
  end

  def test_should_update_user
    put :update, :locale => 'en', :id => users(:basic_user).id, :user => { }
    assert_redirected_to user_path(assigns(:user))
  end

  def test_should_destroy_user
    assert_difference('User.count', -1) do
      delete :destroy, :locale => 'en', :id => users(:basic_user).id
    end

    assert_redirected_to users_path
  end
end
