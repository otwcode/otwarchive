require 'test_helper'

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
    work.add_default_tags
    work.reload
    assert_difference('Chapter.count') do
      post :create, :locale => 'en', :work_id => work.id, 
      :chapter => {:content => random_chapter, :published_at => Date.today, :author_attributes => {:ids => [work.pseuds.first.id]}}
    end
    assert_redirected_to preview_work_chapter_path(assigns(:work),assigns(:chapter))
  end
  # Test destroy  DELETE /:locale/chapters/:id
  # Test destroy  DELETE /:locale/works/:work_id/chapters/:id
  def test_destroy_work_chapter_fail
    chapter = new_chapter
    work = create_work(:chapters => [chapter])
    work.add_default_tags
    delete :destroy, :locale => 'en', :work_id => work.id, :id => chapter.id
    assert flash.has_key?(:error)
    assert_redirected_to work_url(assigns(:work))
    assert_equal Work.find(work.id).number_of_chapters, 1
  end
  def test_destroy_work_chapter
    user = create_user
    @request.session[:user] = user
    pseud = user.pseuds.first
    chapter1 = new_chapter(:authors => [pseud])
    chapter2 = new_chapter(:authors => [pseud])
    work = create_work(:chapters => [chapter1, chapter2], :authors => [pseud])
    work.add_default_tags
    work.update_attribute(:posted, true)
    assert_difference('Chapter.count', -1) do
      delete :destroy, :work_id => work.id, :id => chapter1.id
    end
    assert_redirected_to work_url(assigns(:work))
    assert_equal Work.find(work.id).number_of_chapters, 1
  end  
  # Test edit  GET  /:locale/chapters/:id/edit  (named path: edit_chapter)
  # Test edit  GET  /:locale/works/:work_id/chapters/:id/edit  (named path: edit_work_chapter)
  def test_edit_work_chapter_path
    user = create_user
    @request.session[:user] = user
    chapter = new_chapter(:authors => user.pseuds)
    work = create_work(:chapters => [chapter], :authors => user.pseuds)
    work.add_default_tags
    get :edit, :locale => 'en', :work_id => work.id, :id => chapter.id
    assert_response :success
    assert_equal work, assigns(:work)
    assert_equal chapter, assigns(:chapter)
    assert_equal work.pseuds, assigns(:pseuds)
    assert_equal user.pseuds.collect{|p| p.id}, assigns(:selected_pseuds)
  end
  # Test index  GET  /:locale/chapters  (named path: chapters)
  # Test index  GET  /:locale/works/:work_id/chapters  (named path: work_chapters)
  # unused path. redirect to work
  def test_work_chapters_path
    chapter = new_chapter
    work = create_work(:chapters => [chapter])
    work.add_default_tags
    work.update_attribute("posted", true)
    get :index, :locale => 'en', :work_id => work.id
    assert_redirected_to work_path(work.id)
  end
  # Test new  GET  /:locale/chapters/new  (named path: new_chapter)
  # Test new  GET  /:locale/works/:work_id/chapters/new  (named path: new_work_chapter)
  def test_new_work_chapter_fails
    chapter = new_chapter
    work = create_work(:chapters => [chapter])
    work.add_default_tags
    get :new, :locale => 'en', :work_id => work.id
    assert_redirected_to new_session_path
  end
  def test_new_work_chapter_as_admin
    admin = create_admin
    @request.session[:admin] = admin
    chapter = new_chapter
    work = create_work(:chapters => [chapter])
    work.add_default_tags
    get :new, :locale => 'en', :work_id => work.id
    assert_redirected_to new_session_path
  end
  def test_new_work_chapter_path
    user = create_user
    @request.session[:user] = user    
    chapter = new_chapter
    work = create_work(:chapters => [chapter])
    work.add_default_tags
    work.pseuds << user.pseuds
    get :new, :locale => 'en', :work_id => work.id
    assert_equal work, assigns(:work)
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
    work.add_default_tags
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
    work.add_default_tags
    get :preview, :locale => 'en', :work_id => work.id, :id => chapter.id
    assert_response :success
    assert_equal work, assigns(:work)
    assert_equal chapter, assigns(:chapter)
  end
  # Test show  GET  /:locale/chapters/:id  (named path: chapter)
  # Test show  GET  /:locale/works/:work_id/chapters/:id  (named path: work_chapter)
  def test_work_chapter_path
    chapter = new_chapter
    work = create_work(:chapters => [chapter])
    work.add_default_tags
    work.update_attribute('posted', true)
    get :show, :locale => 'en', :work_id => work.id, :id => chapter.id
    assert_response :success
    assert_equal work, assigns(:work)
    assert_equal chapter, assigns(:chapter)
    assert_equal chapter.comments, assigns(:comments)
  end
  # Test update  PUT  /:locale/chapters/:id
  # Test update  PUT  /:locale/works/:work_id/chapters/:id
  def test_update_work_chapter
    user = create_user
    @request.session[:user] = user
    chapter = new_chapter
    work = create_work(:chapters => [chapter], :authors => [user.default_pseud])
    work.add_default_tags
    new_content = random_chapter
    assert_not_equal Chapter.find(chapter.id).content, new_content
    put :update, :locale => 'en', :work_id => work.id, :id => chapter.id, :chapter => { :content => new_content}, :pseud => { :id => chapter.pseuds.collect { |p| p.id }}
    chapter.reload
    assert_equal chapter.content, new_content
  end
end
