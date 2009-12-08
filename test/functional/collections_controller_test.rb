require 'test_helper'

class CollectionsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:collections)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create collection" do
    assert_difference('Collection.count') do
      post :create, :collection => { }
    end

    assert_redirected_to collection_path(assigns(:collection))
  end

  test "should show collection" do
    get :show, :id => collections(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => collections(:one).to_param
    assert_response :success
  end

  test "should update collection" do
    put :update, :id => collections(:one).to_param, :collection => { }
    assert_redirected_to collection_path(assigns(:collection))
  end

  test "should destroy collection" do
    assert_difference('Collection.count', -1) do
      delete :destroy, :id => collections(:one).to_param
    end

    assert_redirected_to collections_path
  end
end
