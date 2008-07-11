require 'test_helper'

class RelatedWorksControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:related_works)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_related_work
    assert_difference('RelatedWork.count') do
      post :create, :related_work => { }
    end

    assert_redirected_to related_work_path(assigns(:related_work))
  end

  def test_should_show_related_work
    get :show, :id => related_works(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => related_works(:one).id
    assert_response :success
  end

  def test_should_update_related_work
    put :update, :id => related_works(:one).id, :related_work => { }
    assert_redirected_to related_work_path(assigns(:related_work))
  end

  def test_should_destroy_related_work
    assert_difference('RelatedWork.count', -1) do
      delete :destroy, :id => related_works(:one).id
    end

    assert_redirected_to related_works_path
  end
end
