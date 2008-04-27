require File.dirname(__FILE__) + '/../test_helper'

class WorksControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index, :locale => 'en'
    assert_response :success
    assert_not_nil assigns(:works)
  end

  def test_should_get_new
    login_as_user(:basic_user)
    get :new, :locale => 'en'
    assert_response :success
  end

  def test_should_create_work
    login_as_user(:basic_user)
    assert_difference('Work.count') do
      post :create, :locale => 'en', :work => { }
    end

    assert_redirected_to work_path(assigns(:work))
  end

  def test_should_show_work
    get :show, :locale => 'en', :id => works(:basic_work).id
    assert_response :success
  end

  def test_should_get_edit
    login_as_user(:basic_user)
    get :edit, :locale => 'en', :id => works(:basic_work).id
    assert_response :success
  end

  def test_should_update_work
    new_title = "New Title"
    work = works(:basic_work)
    login_as_user(:basic_user)
    put :update, :locale => 'en', :id => work.id, :work => { :metadata => {:title => new_title} }
    assert_redirected_to work_path(assigns(:work))
    assert_equal(new_title, work.metadata.title)
  end
  
  def test_should_destroy_work
    assert_difference('Work.count', -1) do
      delete :destroy, :locale => 'en', :id => works(:basic_work).id
    end

    assert_redirected_to works_path
  end
end
