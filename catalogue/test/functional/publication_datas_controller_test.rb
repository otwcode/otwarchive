require File.dirname(__FILE__) + '/../test_helper'

class PublicationDatasControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:publication_datas)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_publication_data
    assert_difference('PublicationData.count') do
      post :create, :publication_data => { }
    end

    assert_redirected_to publication_data_path(assigns(:publication_data))
  end

  def test_should_show_publication_data
    get :show, :id => publication_datas(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => publication_datas(:one).id
    assert_response :success
  end

  def test_should_update_publication_data
    put :update, :id => publication_datas(:one).id, :publication_data => { }
    assert_redirected_to publication_data_path(assigns(:publication_data))
  end

  def test_should_destroy_publication_data
    assert_difference('PublicationData.count', -1) do
      delete :destroy, :id => publication_datas(:one).id
    end

    assert_redirected_to publication_datas_path
  end
end
