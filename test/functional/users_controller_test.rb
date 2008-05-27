require File.dirname(__FILE__) + '/../test_helper'

class UsersControllerTest < ActionController::TestCase
  # TODO error checking 
  
  # Test activate  activate  /activate/:id
   # TODO test activate
  # Test create  POST  /:locale/users
  def test_create_user
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
  # Test destroy  DELETE /:locale/users/:id
  def test_destroy_user
    user = create_user
    @request.session[:user] = user
    assert_difference('User.count', -1) do
      delete :destroy, :locale => 'en', :id => user.login
    end

    assert_redirected_to users_path
  end
  # Test edit  GET  /:locale/users/:id/edit  (named path: edit_user)
  def test_edit_user_path
    user = create_user
    @request.session[:user] = user
    get :edit, :locale => 'en', :id => user.login
    assert_response :success
  end
  # Test index  GET  /:locale/users  (named path: users)
  # TODO test index
  # Test new  GET  /:locale/users/new  (named path: new_user)
  def test_new_user_path
    get :new, :locale => 'en'
    assert_response :success
  end
  # Test show  GET  /:locale/users/:id  (named path: user)
  def test_user_path
    user = create_user
    get :show, :locale => 'en', :id => user.login
    assert_response :success
  end
  # Test update  PUT  /:locale/users/:id
  def test_update_user
    # FIXME DoubleRenderError
#    user = create_user
#    put :update, :locale => 'en', :id => user.login, :user => {:email => 'new@google.com'}
#    assert_redirected_to user_path(assigns(:user))
#    assert_equal 'new@google.com', User.find(user.id).email
  end
end
