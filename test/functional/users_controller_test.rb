require File.dirname(__FILE__) + '/../test_helper'

class UsersControllerTest < ActionController::TestCase
  def test_should_get_new
    get :new, :locale => 'en'
    assert_response :success
  end

  def test_should_create_user
    assert_difference('User.count') do
      post :create, :locale => 'en', :user => { }
    end

    assert_redirected_to user_path(assigns(:user))
  end

  def test_should_show_user
    get :show, :locale => 'en', :id => users(:user1).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :locale => 'en', :id => users(:user1).id
    assert_response :success
  end

  def test_should_update_user
    put :update, :locale => 'en', :id => users(:user1).id, :user => { }
    assert_redirected_to user_path(assigns(:user))
  end

  def test_should_destroy_user
    assert_difference('User.count', -1) do
      delete :destroy, :locale => 'en', :id => users(:user1).id
    end

    assert_redirected_to users_path
  end
end
