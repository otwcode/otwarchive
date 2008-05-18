require File.dirname(__FILE__) + '/../test_helper'

class ChaptersControllerTest < ActionController::TestCase

  # GET    /:locale/works/:work_id/chapters :action=>"index"
  def test_work_chapters
    # TODO check chapter order
    work = create_work
    chapters = []
    (1..10).each do |i|
     chapters << create_chapter(:work => work)
     get :index, :locale => 'en', :work_id => work.id
     assert_response :success
     assert_equal assigns(:work), work
     assert_equal assigns(:chapters), chapters
    end
  end
  
  # POST   /:locale/works/:work_id/chapters :action=>"create"
  def test_create_chapter
    user = create_user
    @request.session[:user] = user    
    work = create_work
    work.pseuds << user.pseuds
    assert_difference('Chapter.count') do
      post :create, :locale => 'en', :work_id => work.id, :chapter => { :content => random_chapter, :new_metadata_attributes => {:title => random_phrase, "notes"=>"", "summary"=>""}}, :pseud => { :id => user.pseuds.collect { |p| p.id } }
    end
    assert_redirected_to preview_work_chapter_path(assigns(:work),assigns(:chapter))
  end

  # GET    /:locale/works/:work_id/chapters/new :action=>"new"
  def test_new_work_chapter
    user = create_user
    @request.session[:user] = user    
    work = create_work
    work.pseuds << user.pseuds
    get :new, :locale => 'en', :work_id => work.id
    assert_equal assigns(:work), work
    assert_response :success
  end

  # POST   /:locale/works/:work_id/chapters/:id/post  :action=>"post"
  def test_post_work_chapter
    # FIXME should need to be chapter's author to post
    user = create_user
    @request.session[:user] = user  
    work = create_work
    chapter = create_chapter(:work => work)
    post :post, :locale => 'en', :work_id => work.id, :id => chapter.id  
    assert Chapter.find(chapter.id).posted
    assert_redirected_to work_path(assigns(:work))
    assert flash[:notice] =~ /posted/
  end

  # GET    /:locale/works/:work_id/chapters/:id/edit  :action=>"edit"
  def test_edit_work_chapter
    user = create_user
    @request.session[:user] = user
    work = create_work
    work.pseuds << user.pseuds    
    chapter = create_chapter(:work => work)
    chapter.pseuds << user.pseuds
    get :edit, :locale => 'en', :work_id => work.id, :id => chapter.id
    assert_response :success
    assert_equal assigns(:work), work
    assert_equal assigns(:chapter), chapter
    assert_equal assigns(:pseuds), work.pseuds
    assert_equal assigns(:selected), chapter.pseuds.collect{|p| p.id}
  end

  # GET    /:locale/works/:work_id/chapters/:id/preview :action=>"preview"
  def test_preview_work_chapter
    # FIXME should need to be chapter's author to preview
    user = create_user
    @request.session[:user] = user
    work = create_work
    chapter = create_chapter(:work => work)
    get :preview, :locale => 'en', :work_id => work.id, :id => chapter.id
    assert_response :success
    assert_equal assigns(:work), work
    assert_equal assigns(:chapter), chapter
  end

  # GET    /:locale/works/:work_id/chapters/:id :action=>"show"
  def test_work_chapter
    work = create_work
    chapter = create_chapter(:work => work)
    get :show, :locale => 'en', :work_id => work.id, :id => chapter.id
    assert_response :success
    assert_equal assigns(:work), work
    assert_equal assigns(:chapter), chapter
    assert_equal assigns(:comments), chapter.comments
  end
  
  # PUT    /:locale/works/:work_id/chapters/:id   :action=>"update"
  def test_update_chapter
    user = create_user
    @request.session[:user] = user
    work = create_work
    chapter = create_chapter(:work => work)
    chapter.pseuds << user.pseuds    
    new_content = random_chapter
    assert_not_equal Chapter.find(chapter.id).content, new_content
    put :update, :locale => 'en', :work_id => work.id, :id => chapter.id, :chapter => { :content => new_content}, :pseud => { :id => chapter.pseuds.collect { |p| p.id }}
    assert_equal Chapter.find(chapter.id).content, new_content
  end
  
  # DELETE /:locale/works/:work_id/chapters/:id :action=>"destroy"
  # FIXME shouldn't be able to destroy the only chapter in a work.
  def test_destroy_only_chapter
    work = create_work
    chapter1 = create_chapter(:work => work) 
    chapter2 = create_chapter(:work => work) 
    work.chapters << [chapter1, chapter2]
#    delete :destroy, :locale => 'en', :work_id => work.id, :id => chapter1.id
#    assert flash.has_key?(:error)
  end

  def test_destroy_chapter
    work = create_work
    chapter1 = create_chapter(:work => work) 
    chapter2 = create_chapter(:work => work) 
    work.chapters << [chapter1, chapter2]
    assert_difference('Chapter.count', -1) do
      delete :destroy, :locale => 'en', :work_id => work.id, :id => chapter1.id
    end
    assert_redirected_to work_chapters_path(assigns(:work))
    assert_equal Work.find(work.id).number_of_chapters, 1
  end
end
