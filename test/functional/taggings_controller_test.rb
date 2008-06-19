require File.dirname(__FILE__) + '/../test_helper'

class TaggingsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index, :locale => 'en'
    assert_response :success
    assert_not_nil assigns(:taggings)
  end

  def test_should_get_new
    get :new, :locale => 'en'
    assert_response :success
  end

  def test_should_create_tagging
    assert_difference('Tagging.count') do
      post :create, :tagging => { :tag => create_tag, :taggable => create_work }, :locale => 'en'
    end

    assert_redirected_to tagging_path(assigns(:tagging))
  end

  def test_should_show_tagging
    tagging = create_tagging(:taggable => create_tag)
    get :show, :id => tagging.id, :locale => 'en'
    assert_response :success
  end

  def test_should_get_edit
    tagging = create_tagging(:taggable => create_tag)
    get :edit, :id => tagging.id, :locale => 'en'
    assert_response :success
  end

  def test_should_update_tagging
    tagging = create_tagging(:taggable => create_tag)
    put :update, :id => tagging.id, :tagging => { }, :locale => 'en'
    assert_redirected_to tagging_path(assigns(:tagging))
  end

  def test_should_destroy_tagging
    tagging = create_tagging
    assert_difference('Tagging.count', -1) do
      delete :destroy, :id => tagging.id, :locale => 'en'
    end

    assert_redirected_to taggings_path
  end
end
