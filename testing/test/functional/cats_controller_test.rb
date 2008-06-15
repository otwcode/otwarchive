require File.dirname(__FILE__) + '/../test_helper'

class CatsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:cats)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_cat
    assert_difference('Cat.count') do
      post :create, :cat => { }
    end

    assert_redirected_to cat_path(assigns(:cat))
  end

  def test_should_show_cat
    get :show, :id => cats(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => cats(:one).id
    assert_response :success
  end

  def test_should_update_cat
    put :update, :id => cats(:one).id, :cat => { }
    assert_redirected_to cat_path(assigns(:cat))
  end

  def test_should_destroy_cat
    assert_difference('Cat.count', -1) do
      delete :destroy, :id => cats(:one).id
    end

    assert_redirected_to cats_path
  end
end
