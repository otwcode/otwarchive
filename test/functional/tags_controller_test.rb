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
      post :create, :tag => {:name => random_word, :tag_category_id => 1 }, :locale => 'en'
    end
    assert_redirected_to tag_relationships_path
  end

  def test_should_show_tag
    tag = create_tag
    get :show, :id => tag.id, :locale => 'en'
    assert_response :success
  end

end
