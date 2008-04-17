require File.dirname(__FILE__) + '/../test_helper'

class WorksControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:works)
  end

  def test_should_get_new
    login_as_user(:user1)
    get :new
    assert_response :success
  end

  def test_should_create_work
    login_as_user(:user1)
    assert_difference('Work.count') do
      post :create, :work => { }
    end

    assert_redirected_to work_path(assigns(:work))
  end

  def test_should_show_work
    get :show, :id => works(:basic_work).id
    assert_response :success
  end

  def test_should_get_edit
    login_as_user(:user1)
    get :edit, :id => works(:basic_work).id
    assert_response :success
  end

  def test_should_update_work
    put :update, :id => works(:basic_work).id, :work => { }
    assert_redirected_to work_path(assigns(:work))
  end
  
  def test_should_destroy_work
    assert_difference('Work.count', -1) do
      delete :destroy, :id => works(:basic_work).id
    end

    assert_redirected_to works_path
  end
end
