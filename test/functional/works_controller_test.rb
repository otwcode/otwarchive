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
  
  # Currently this only tests the first step of work creation
  def test_should_create_work
    login_as_user(:basic_user)
    
    get :new, :locale => 'en'
    submit_form 'work_form' do |form|
      form.pseud.id = '1'
      form.metadata_attributes.title = 'New work title'
      form.chapter_attributes.content = 'Stuff in new chapter'
    end
    assert_response :success
  end
  
  def test_should_show_work
    get :show, :locale => 'en', :id => works(:basic_work).id
    assert_response :success
  end
  
  def test_should_get_edit
    login_as_user(:basic_user)
    @work = works(:basic_work)
    get :edit, :locale => 'en', :id => @work.id
    assert_response :success
  end
  
  def test_should_update_work
    login_as_user(:basic_user)
    @work = works(:basic_work)
    
    new_title = "New Title"
    new_content = "New Content"
    
    get :edit, :locale => 'en', :id => @work.id
    select_link('Edit work').follow
    assert_response :success

    put :update, :locale => 'en', :id => @work.id, :work => { :metadata_attributes => {:title => new_title}, 
                                                              :chapter_attributes => {:content => new_content}, 
                                                              :pseud => {:id => '1'},
                                                              :extra_pseuds => '' }
#    assert_redirected_to work_path(assigns(:work))
    assert_equal(new_title, @work.metadata.title)
    assert_equal(new_content, @work.chapters.first.content)
    
  end
  
  def test_should_destroy_work
    assert_difference('Work.count', -1) do
      delete :destroy, :locale => 'en', :id => works(:basic_work).id
    end
    
    assert_redirected_to works_path
  end
end
