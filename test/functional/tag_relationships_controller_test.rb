require File.dirname(__FILE__) + '/../test_helper'

class TagRelationshipsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index, :locale => 'en'
    assert_response :success
    assert_not_nil assigns(:tag_relationships)
  end

  def test_should_get_new
    get :new, :locale => 'en'
    assert_response :success
  end

  def test_should_create_tag_relationship
    assert_difference('TagRelationship.count') do
      post :create, :tag_relationship => { :name => random_word, :verb_phrase => random_phrase }
    end

    assert_redirected_to tag_relationship_path(assigns(:tag_relationship))
  end

  def test_should_show_tag_relationship
    tag_relationship = create_tag_relationship
    get :show, :id => tag_relationship.id, :locale => 'en'
    assert_response :success
  end

  def test_should_get_edit
    tag_relationship = create_tag_relationship
    get :edit, :id => tag_relationship.id, :locale => 'en'
    assert_response :success
  end

  def test_should_update_tag_relationship
    tag_relationship = create_tag_relationship
    put :update, :id => tag_relationship.id, :tag_relationship => { }, :locale => 'en'
    assert_redirected_to tag_relationship_path(assigns(:tag_relationship))
  end

  def test_should_destroy_tag_relationship
    tag_relationship = create_tag_relationship
    assert_difference('TagRelationship.count', -1) do
      delete :destroy, :id => tag_relationship.id, :locale => 'en'
    end

    assert_redirected_to tag_relationships_path
  end
end
