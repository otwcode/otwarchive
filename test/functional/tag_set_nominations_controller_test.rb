require 'test_helper'

class TagSetNominationsControllerTest < ActionController::TestCase
  setup do
    @tag_set_nomination = tag_set_nominations(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:tag_set_nominations)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create tag_set_nomination" do
    assert_difference('TagSetNomination.count') do
      post :create, :tag_set_nomination => @tag_set_nomination.attributes
    end

    assert_redirected_to tag_set_nomination_path(assigns(:tag_set_nomination))
  end

  test "should show tag_set_nomination" do
    get :show, :id => @tag_set_nomination.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @tag_set_nomination.to_param
    assert_response :success
  end

  test "should update tag_set_nomination" do
    put :update, :id => @tag_set_nomination.to_param, :tag_set_nomination => @tag_set_nomination.attributes
    assert_redirected_to tag_set_nomination_path(assigns(:tag_set_nomination))
  end

  test "should destroy tag_set_nomination" do
    assert_difference('TagSetNomination.count', -1) do
      delete :destroy, :id => @tag_set_nomination.to_param
    end

    assert_redirected_to tag_set_nominations_path
  end
end
