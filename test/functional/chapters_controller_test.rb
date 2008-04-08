require File.dirname(__FILE__) + '/../test_helper'

class ChaptersControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:chapters)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_chapter
    assert_difference('Chapter.count') do
      post :create, :chapter => { }
    end

    assert_redirected_to chapter_path(assigns(:chapter))
  end

  def test_should_show_chapter
    get :show, :id => chapters(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => chapters(:one).id
    assert_response :success
  end

  def test_should_update_chapter
    put :update, :id => chapters(:one).id, :chapter => { }
    assert_redirected_to chapter_path(assigns(:chapter))
  end

  def test_should_destroy_chapter
    assert_difference('Chapter.count', -1) do
      delete :destroy, :id => chapters(:one).id
    end

    assert_redirected_to chapters_path
  end
end
