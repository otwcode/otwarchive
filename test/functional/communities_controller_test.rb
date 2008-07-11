require 'test_helper'

class CommunitiesControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:communities)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_community
    assert_difference('Community.count') do
      post :create, :community => { }
    end

    assert_redirected_to community_path(assigns(:community))
  end

  def test_should_show_community
    get :show, :id => communities(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => communities(:one).id
    assert_response :success
  end

  def test_should_update_community
    put :update, :id => communities(:one).id, :community => { }
    assert_redirected_to community_path(assigns(:community))
  end

  def test_should_destroy_community
    assert_difference('Community.count', -1) do
      delete :destroy, :id => communities(:one).id
    end

    assert_redirected_to communities_path
  end
end
