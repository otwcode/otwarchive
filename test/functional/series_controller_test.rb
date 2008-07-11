require 'test_helper'

class SeriesControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:series)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_series
    assert_difference('Series.count') do
      post :create, :series => { }
    end

    assert_redirected_to series_path(assigns(:series))
  end

  def test_should_show_series
    get :show, :id => series(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => series(:one).id
    assert_response :success
  end

  def test_should_update_series
    put :update, :id => series(:one).id, :series => { }
    assert_redirected_to series_path(assigns(:series))
  end

  def test_should_destroy_series
    assert_difference('Series.count', -1) do
      delete :destroy, :id => series(:one).id
    end

    assert_redirected_to series_path
  end
end
