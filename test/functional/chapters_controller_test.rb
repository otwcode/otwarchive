require File.dirname(__FILE__) + '/../test_helper'

class ChaptersControllerTest < ActionController::TestCase
  # TODO all non-work chapter routes
  # TODO more tests of before filters
  
  # Test create  POST  /:locale/chapters
  # Test create  POST  /:locale/works/:work_id/chapters
  def test_create_work_chapter
    user = create_user
    @request.session[:user] = user    
    chapter = new_chapter
    work = create_work(:chapters => [chapter], :authors => user.pseuds)
    work.reload
    assert_difference('Chapter.count') do
      post :create, :locale => 'en', :work_id => work.id, 
      :chapter => {:content => random_chapter, :author_attributes => {:ids => [work.pseuds.first.id]}}
    end
    assert_redirected_to preview_work_chapter_path(assigns(:work),assigns(:chapter))
  end
  # Test destroy  DELETE /:locale/chapters/:id
  # Test destroy  DELETE /:locale/works/:work_id/chapters/:id
  def test_destroy_work_chapter_fail
    chapter = new_chapter
    work = create_work(:chapters => [chapter])
    delete :destroy, :locale => 'en', :work_id => work.id, :id => chapter.id
    assert flash.has_key?(:error)
    assert_redirected_to edit_work_url(assigns(:work))
    assert_equal Work.find(work.id).number_of_chapters, 1
  end
  def test_destroy_work_chapter
    # FIXME - this should fail - no session means anyone can do it...
    pseud = create_pseud
    chapter1 = new_chapter(:authors => [pseud])
    chapter2 = new_chapter(:authors => [pseud])
    work = create_work(:chapters => [chapter1, chapter2], :authors => [pseud])
    work.update_attribute(:posted, true)
    assert_difference('Chapter.count', -1) do
      delete :destroy, :locale => 'en', :work_id => work.id, :id => chapter1.id
    end
    assert_redirected_to edit_work_url(assigns(:work))
    assert_equal Work.find(work.id).number_of_chapters, 1
  end  
  # Test edit  GET  /:locale/chapters/:id/edit  (named path: edit_chapter)
  # Test edit  GET  /:locale/works/:work_id/chapters/:id/edit  (named path: edit_work_chapter)
  def test_edit_work_chapter_path
    user = create_user
    @request.session[:user] = user
    chapter = new_chapter(:authors => user.pseuds)
    work = create_work(:chapters => [chapter], :authors => user.pseuds)
    get :edit, :locale => 'en', :work_id => work.id, :id => chapter.id
    assert_response :success
    assert_equal assigns(:work), work
    assert_equal assigns(:chapter), chapter
    assert_equal assigns(:pseuds), work.pseuds
    assert_equal assigns(:selected), user.pseuds.collect{|p| p.id}
  end
  # Test index  GET  /:locale/chapters  (named path: chapters)
  # Test index  GET  /:locale/works/:work_id/chapters  (named path: work_chapters)
  def test_work_chapters_path
    chapter = new_chapter
    work = create_work(:chapters => [chapter])
    get :index, :locale => 'en', :work_id => work.id
    assert_response :success
    assert_equal assigns(:work), work
    assert_equal assigns(:chapters), []
    chapter.posted = true
    chapter.save
    get :index, :locale => 'en', :work_id => work.id
    assert_equal assigns(:chapters), [chapter]
    new_chapter = create_chapter(:work => work, :posted=> true, :authors => work.pseuds)
    get :index, :locale => 'en', :work_id => work.id
    assert_response :success
    assert_equal assigns(:work), work
    assert_equal assigns(:chapters), [chapter, new_chapter]
  end
  # Test new  GET  /:locale/chapters/new  (named path: new_chapter)
  # Test new  GET  /:locale/works/:work_id/chapters/new  (named path: new_work_chapter)
  def test_new_work_chapter_fails
    chapter = new_chapter
    work = create_work(:chapters => [chapter])
    get :new, :locale => 'en', :work_id => work.id
    assert_redirected_to new_session_path
  end
  def test_new_work_chapter_as_admin
    admin = create_admin
    @request.session[:admin] = admin
    chapter = new_chapter
    work = create_work(:chapters => [chapter])
    get :new, :locale => 'en', :work_id => work.id
    assert_redirected_to new_session_path
  end
  def test_new_work_chapter_path
    user = create_user
    @request.session[:user] = user    
    chapter = new_chapter
    work = create_work(:chapters => [chapter])
    work.pseuds << user.pseuds
    get :new, :locale => 'en', :work_id => work.id
    assert_equal assigns(:work), work
    assert_response :success
  end
  # Test post  POST  /:locale/chapters/:id/post  (named path: post_chapter)
  # Test post  POST  /:locale/works/:work_id/chapters/:id/post  (named path: post_work_chapter)
  def test_post_work_chapter_path
    # FIXME should need to be chapter's author to post
    user = create_user
    @request.session[:user] = user  
    chapter = new_chapter
    work = create_work(:chapters => [chapter])
    post :post, :locale => 'en', :work_id => work.id, :id => chapter.id  
    assert Chapter.find(chapter.id).posted
    assert_redirected_to work_path(assigns(:work))
    assert flash[:notice] =~ /posted/
  end
  # Test preview  GET  /:locale/chapters/:id/preview  (named path: preview_chapter)
  # Test preview  GET  /:locale/works/:work_id/chapters/:id/preview  (named path: preview_work_chapter)
  def test_preview_work_chapter_path
    # FIXME should need to be chapter's author to preview
    user = create_user
    @request.session[:user] = user
    chapter = new_chapter
    work = create_work(:chapters => [chapter])
    get :preview, :locale => 'en', :work_id => work.id, :id => chapter.id
    assert_response :success
    assert_equal assigns(:work), work
    assert_equal assigns(:chapter), chapter
  end
  # Test show  GET  /:locale/chapters/:id  (named path: chapter)
  # Test show  GET  /:locale/works/:work_id/chapters/:id  (named path: work_chapter)
  def test_work_chapter_path
    chapter = new_chapter
    work = create_work(:chapters => [chapter])
    work.update_attribute('posted', true)
    get :show, :locale => 'en', :work_id => work.id, :id => chapter.id
    assert_response :success
    assert_equal assigns(:work), work
    assert_equal assigns(:chapter), chapter
    assert_equal assigns(:comments), chapter.comments
  end
  # Test update  PUT  /:locale/chapters/:id
  # Test update  PUT  /:locale/works/:work_id/chapters/:id
  def test_update_work_chapter
    user = create_user
    @request.session[:user] = user
    chapter = new_chapter
    work = create_work(:chapters => [chapter], :authors => [user.default_pseud])
    new_content = random_chapter
    assert_not_equal Chapter.find(chapter.id).content, new_content
    put :update, :locale => 'en', :work_id => work.id, :id => chapter.id, :chapter => { :content => new_content}, :pseud => { :id => chapter.pseuds.collect { |p| p.id }}
    chapter.reload
    assert_equal chapter.content, new_content
  end
end
