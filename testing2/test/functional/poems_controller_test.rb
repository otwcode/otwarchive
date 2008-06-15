require File.dirname(__FILE__) + '/../test_helper'

class PoemsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:poems)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_poem
    assert_difference('Poem.count') do
      post :create, :poem => { }
    end

    assert_redirected_to poem_path(assigns(:poem))
  end

  def test_should_show_poem
    get :show, :id => poems(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => poems(:one).id
    assert_response :success
  end

  def test_should_update_poem
    put :update, :id => poems(:one).id, :poem => { }
    assert_redirected_to poem_path(assigns(:poem))
  end

  def test_should_destroy_poem
    assert_difference('Poem.count', -1) do
      delete :destroy, :id => poems(:one).id
    end

    assert_redirected_to poems_path
  end
end
