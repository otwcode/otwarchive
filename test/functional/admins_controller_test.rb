require File.dirname(__FILE__) + '/../test_helper'

class AdminsControllerTest < ActionController::TestCase
    
  def test_should_get_index
    login_as_admin(:admin)
    get :index, :locale => 'en'
    assert_response :success
    assert_not_nil assigns(:admins)
  end

  def test_should_show_admin
    login_as_admin(:admin)
    get :show, :locale => 'en', :id => admins(:admin).id
    assert_response :success
  end

  def test_should_destroy_admin
    login_as_admin(:admin)
    assert_difference('Admin.count', -1) do
      delete :destroy, :locale => 'en', :id => admins(:admin_to_destroy).id
    end

    assert_redirected_to admins_path
  end
end
