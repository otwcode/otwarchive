require File.dirname(__FILE__) + '/../test_helper'

class WorksControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:works)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_work
    assert_difference('Work.count') do
      post :create, :work => { }
    end

    assert_redirected_to work_path(assigns(:work))
  end

  def test_should_show_work
    get :show, :id => works(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => works(:one).id
    assert_response :success
  end

  def test_should_update_work
    put :update, :id => works(:one).id, :work => { }
    assert_redirected_to work_path(assigns(:work))
  end

  def test_should_destroy_work
    assert_difference('Work.count', -1) do
      delete :destroy, :id => works(:one).id
    end

    assert_redirected_to works_path
  end
end
