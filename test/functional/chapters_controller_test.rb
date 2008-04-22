require File.dirname(__FILE__) + '/../test_helper'

class ChaptersControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index, :locale => 'en', :work_id => works(:basic_work).id
    assert_response :success
    assert_not_nil assigns(:chapters)
  end

  def test_should_get_new
    get :new, :locale => 'en', :work_id => works(:basic_work).id
    assert_response :success
  end

  def test_should_create_chapter
    assert_difference('Chapter.count') do
      post :create, :locale => 'en', :work_id => works(:basic_work).id, :chapter => { :content => 'Some content woo' }
    end

    assert_redirected_to chapter_path(assigns(:chapter))
  end

  def test_should_show_chapter
    get :show, :locale => 'en', :work_id => works(:basic_work).id, :id => chapters(:basic_chapter).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :locale => 'en', :work_id => works(:basic_work).id, :id => chapters(:basic_chapter).id
    assert_response :success
  end

  def test_should_update_chapter
    put :update, :locale => 'en', :work_id => works(:basic_work).id, :id => chapters(:basic_chapter).id, :chapter => { }
    assert_redirected_to chapter_path(assigns(:chapter))
  end

  def test_should_destroy_chapter
    assert_difference('Chapter.count', -1) do
      delete :destroy, :locale => 'en', :work_id => works(:basic_work).id, :id => chapters(:basic_chapter).id
    end

    assert_redirected_to chapters_path
  end
end
