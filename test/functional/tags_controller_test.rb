require File.dirname(__FILE__) + '/../test_helper'

class TagsControllerTest < ActionController::TestCase
  def test_should_get_index
    tag = create_tag
    get :index, :locale => 'en'
    assert_response :success
    assert_not_nil assigns(:tags)
  end

  def test_should_get_new
    get :new, :locale => 'en'
    assert_response :success
  end

  def test_should_create_tag
    assert_difference('Tag.count') do
      post :create, :tag => {:name => random_word }, :locale => 'en'
    end

    assert_redirected_to tag_path(assigns(:tag))
  end

  def test_should_show_tag
    tag = create_tag
    get :show, :id => tag.id, :locale => 'en'
    assert_response :success
  end

  def test_should_get_edit
    tag = create_tag
    get :edit, :id => tag.id, :locale => 'en'
    assert_response :success
  end

  def test_should_update_tag
    tag = create_tag
    put :update, :id => tag.id, :tag => { }, :locale => 'en'
    assert_redirected_to tag_path(assigns(:tag))
  end

end
