require File.dirname(__FILE__) + '/../test_helper'

# TODO error checking
# TODO work as admin
class WorksControllerTest < ActionController::TestCase

  # Test create  POST  /:locale/works
  def test_create_work
    user = create_user
    @request.session[:user] = user    
    get :new, :locale => 'en', 
        :work => { :metadata_attributes => {:title => 'New work title'}, 
                   :chapter_attributes => {:content => 'Stuff in new chapter'}}
    assert_response :success
  end
  # Test destroy  DELETE /:locale/works/:id
  def test_should_destroy_work
    user = create_user
    @request.session[:user] = user
    @work = create_work(:authors => [user.default_pseud])
    assert_difference('Work.count', -1) do
      delete :destroy, :locale => 'en', :id => works(:basic_work).id
    end    
    assert_redirected_to works_path
  end
  # Test edit  GET  /:locale/works/:id/edit  (named path: edit_work)
  def test_should_get_edit
    user = create_user
    @request.session[:user] = user
    @work = create_work(:authors => [user.default_pseud])
    get :edit, :locale => 'en', :id => @work.id
    assert_response :success
  end
  # Test index  GET  /:locale/works  (named path: works)
  def test_works_path
    # FIXME Called id for nil if no language
    Locale.set 'en'
    get :index, :locale => 'en'
    assert_response :success
    assert_not_nil assigns(:works)
  end
  # Test new  GET  /:locale/works/new  (named path: new_work)
  def test_new_work_path
    login_as_user(:basic_user)
    get :new, :locale => 'en'
    assert_response :success
  end
  # Test post  POST  /:locale/works/:id/post  (named path: post_work)
    # TODO test post
  # Test preview  GET  /:locale/works/:id/preview  (named path: preview_work)
    # TODO test preview
  # Test show  GET  /:locale/works/:id  (named path: work)
  def test_work_path
    get :show, :locale => 'en', :id => works(:basic_work).id
    assert_response :success
    # TODO test comments
  end
  # Test update  PUT  /:locale/works/:id
  def test_update_work
    user = create_user
    @request.session[:user] = user
    @work = create_work(:authors => [user.default_pseud])    
    new_title = "New Title"
    new_content = "New Content"
    put :update, 
        :locale => 'en', 
        :id => @work.id, 
        :work => { :metadata_attributes => {:title => new_title}, 
                   :chapter_attributes => {:content => new_content}}
    assert_redirected_to work_path(assigns(:work))
    @work = Work.find(@work.id)
    assert_equal(new_title, @work.metadata.title)
    assert_equal(new_content, @work.chapters.first.content)    
  end
end
