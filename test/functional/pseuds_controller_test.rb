require File.dirname(__FILE__) + '/../test_helper'

class PseudsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index, :locale => 'en', :user_id => users(:basic_user).id
    assert_response :success
    assert_not_nil assigns(:pseuds)
  end

  def test_should_get_new
    login_as_user(:basic_user)
    get :new, :locale => 'en', :user_id => users(:basic_user).id
    assert_response :success
  end

  def test_should_create_pseud
    login_as_user(:basic_user)
    assert_difference('Pseud.count') do
      post :create, :locale => 'en', :user_id => users(:basic_user).id, :pseud => { :name => 'New Pseud' }
    end

    assert_redirected_to user_pseud_path(users(:basic_user), assigns(:pseud))
  end

  def test_should_show_pseud
    get :show, :locale => 'en', :user_id => users(:basic_user).id, :id => pseuds(:default_pseud).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :locale => 'en', :user_id => users(:basic_user).id, :id => pseuds(:default_pseud).id
    assert_response :success
  end

  def test_should_update_pseud
    login_as_user(:basic_user)
    put :update, :locale => 'en', 
                 :user_id => users(:basic_user).id, 
                 :id => pseuds(:default_pseud).id, 
                 :pseud => { :name => 'Changed Pseud' }
    assert_redirected_to user_pseud_path(users(:basic_user), assigns(:pseud))
  end

  def test_should_destroy_pseud
    login_as_user(:basic_user)
    assert_difference('Pseud.count', -1) do
      delete :destroy, :locale => 'en', :user_id => users(:basic_user).id, :id => pseuds(:non_default_pseud).id
    end

    assert_redirected_to user_pseuds_path(users(:basic_user))
  end
end
