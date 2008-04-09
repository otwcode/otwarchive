require File.dirname(__FILE__) + '/../test_helper'

class AdminsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:admins)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_admin
    assert_difference('Admin.count') do
      post :create, :admin => { }
    end

    assert_redirected_to admin_path(assigns(:admin))
  end

  def test_should_show_admin
    get :show, :id => admins(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => admins(:one).id
    assert_response :success
  end

  def test_should_update_admin
    put :update, :id => admins(:one).id, :admin => { }
    assert_redirected_to admin_path(assigns(:admin))
  end

  def test_should_destroy_admin
    assert_difference('Admin.count', -1) do
      delete :destroy, :id => admins(:one).id
    end

    assert_redirected_to admins_path
  end
end
