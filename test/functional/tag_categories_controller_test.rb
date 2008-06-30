require File.dirname(__FILE__) + '/../test_helper'

class TagCategoriesControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index, :locale => 'en'
    assert_response :success
    assert_not_nil assigns(:tag_categories)
  end

  def test_should_get_new
    get :new, :locale => 'en'
    assert_response :success
  end

  def test_should_create_tag_category
    assert_difference('TagCategory.count') do
      post :create, :tag_category => { :name => random_word }, :locale => 'en'
    end

    assert_redirected_to tag_categories_path
  end

  def test_should_show_tag_category
    tag_category = create_tag_category
    get :show, :id => tag_category.id, :locale => 'en'
    assert_response :success
  end

  def test_should_get_edit
    tag_category = create_tag_category
    get :edit, :id => tag_category.id, :locale => 'en'
    assert_response :success
  end

  def test_should_update_tag_category
    tag_category = create_tag_category
    put :update, :id => tag_category.id, :tag_category => { }, :locale => 'en'
    assert_redirected_to tag_categories_path
  end

  def test_should_destroy_tag_category
    tag_category = create_tag_category
    assert_difference('TagCategory.count', -1) do
      delete :destroy, :id => tag_category.id, :locale => 'en'
    end

    assert_redirected_to tag_categories_path
  end
end
