require 'test_helper'

class CommentsControllerTest < ActionController::TestCase
# FIXME no error checking
# TODO test before filter
# TODO test the rest of the routes
# TODO test the anchor redirects
  def create_comments
    # runs much faster when you don't keep creating new users for everything
    @user = create_user
    @pseud = @user.default_pseud
    @chapter1 = new_chapter(:authors => [@pseud])
    @work = create_work(:chapters => [@chapter1], :authors => [@pseud], :posted => true)
    @chapter1.save
    @chapter2 = new_chapter(:work_id => @work.id, :authors => [@pseud], :posted => true)
    @chapter2.save
    @comment1 = create_comment(:commentable => @chapter1, :content => 'first comment', :pseud => @pseud)
    @comment1.save
    @comment2 = create_comment(:commentable => @chapter2, :content => 'second comment', :pseud => @pseud)
    @comment2.save
    @child1 = create_comment(:commentable => @comment1, :content => 'first child', :pseud => @pseud)
    @child1.save
    @work.reload
  end

  # Test approve  PUT  /:locale/comments/:id/approve  (named path: approve_comment)
  # Test create  POST  /:locale/chapters/:chapter_id/comments
  def test_create_chapter_comment
    create_comments
    # FIXME Called id for nil comments_controller.rb:64
#    assert_difference('Comment.count') do
#      post :create, :locale => 'en',
#                    :chapter_id => @chapter1.id,
#                    :comment => { :content => 'foo',
#                                  :name => 'Someone',
#                                  :email => 'someone@someplace.org' }
#    end
#    assert_redirected_to work_path(:locale => 'en', :id => @work.id)
  end
  # Test create  POST  /:locale/comments
  def test_create_comment_fail
    @request.env['HTTP_REFERER'] = 'http://www.google.com/'
    assert_no_difference('Comment.count') do
      post :create, :comment => { :content => 'foo', :name => 'Someone', :email => 'someone@someplace.org' }
    end
    assert !flash[:error].blank?
    assert_response :redirect
  end
  def test_create_comment_fail_logged_in
    @request.env['HTTP_REFERER'] = 'http://www.google.com/'
    user = create_user
    @request.session[:user] = user
    assert_no_difference('Comment.count') do
      post :create, :comment => { :content => 'foo' }
    end
    assert !flash[:error].blank?
    assert_response :redirect
  end
  # Test create  POST  /:locale/comments/:comment_id/comments
  def test_create_comment_comment
    create_comments
    assert_difference('Comment.count') do
      post :create, :comment_id => @comment1.id,
                    :comment => { :content => 'foo', :name => 'Someone', :email => 'newcommenter@someplace.org' }
    end
    @comment = Comment.find_by_email('newcommenter@someplace.org')
    assert_redirected_to work_path(:id => @work.id, :show_comments => true, :anchor => "comment_#{@comment.id}")
  end
  # Test create  POST  /:locale/works/:work_id/chapters/:chapter_id/comments
  def test_create_work_chapter_comment
    create_comments
    assert_difference('Comment.count') do
      @request.session[:user] = @user
      post :create, :work_id => @work.id,
                    :chapter_id => @chapter1.id,
                    :comment => {"pseud_id"=>@pseud.id,
                                 "content"=>"new chapter"}
    end
    # TODO check redirect
    assert_equal 2, @chapter1.comments.size
  end
  # Test destroy  DELETE /:locale/chapters/:chapter_id/comments/:id
  # Test destroy  DELETE /:locale/comments/:comment_id/comments/:id
  # Test destroy  DELETE /:locale/comments/:id
  def test_delete_comment1
    @request.env['HTTP_REFERER'] = 'http://www.google.com/'
    create_comments
    @request.session[:user] = @user
    assert_no_difference('Comment.count') do
      delete :destroy, :id => @comment1.id
    end
    @comment1.reload
    assert @comment1.is_deleted?
  end
  def test_delete_comment2
    create_comments
    @request.session[:user] = @user
    assert_difference('Comment.count', -1) do
      delete :destroy, :id => @comment2.id
    end
    assert_raises(ActiveRecord::RecordNotFound) { @comment2.reload }
  end
  # Test destroy  DELETE /:locale/works/:work_id/chapters/:chapter_id/comments/:id
  def test_delete_work_chapter_comment
    create_comments
    @request.session[:user] = @user
    delete :destroy, :work_id => @work.id, :chapter_id => @chapter1.id, :id => @comment1.id
    @comment1.reload
    assert @comment1.is_deleted?
  end
  # Test edit  GET  /:locale/chapters/:chapter_id/comments/:id/edit  (named path: edit_chapter_comment)
  def test_edit_chapter_comment_path
    create_comments
    @request.session[:user] = @user
    get :edit, :chapter_id => @chapter1.id, :id => @comment2.id
    assert_response :success
  end
  # Test edit  GET  /:locale/comments/:comment_id/comments/:id/edit  (named path: edit_comment_comment)
  # Test edit  GET  /:locale/comments/:id/edit  (named path: edit_comment)
  def test_edit_comment
    create_comments
    @request.session[:user] = @user
    get :edit, :id => @comment2.id
    assert_response :success
  end
  # Test edit  GET  /:locale/works/:work_id/chapters/:chapter_id/comments/:id/edit  (named path: edit_work_chapter_comment)
  def test_edit_work_chapter_comment_path
    create_comments
    @request.session[:user] = @user
    get :edit, :work_id => @work.id, :chapter_id => @chapter1.id, :id => @comment2.id
    assert_response :success
    assert_not_nil assigns(:commentable)
  end
  # Test index  GET  /:locale/chapters/:chapter_id/comments  (named path: chapter_comments)
  def test_chapter_comments_path1
    create_comments
    get :index, :chapter_id => @chapter2.id, :show_comments => true
    assert_response :success
    assert_no_tag :tag => 'p', :content => 'first comment'
    assert_tag :tag => 'p', :content => 'second comment'
  end
  def test_chapter_comments_path2
    create_comments
    get :index, :chapter_id => @chapter1.id, :show_comments => true
    assert_response :success
    assert_tag :tag => 'p', :content => 'first comment'
    assert_no_tag :tag => 'p', :content => 'second comment'
  end
  # Test index  GET  /:locale/comments  (named path: comments)
  def test_comments_path
    create_comments
    # FIXME You have a nil object
    get :index
    assert_response :success
    assert_tag :tag => 'p', :content => @comment1.content
    assert_tag  :tag => 'p', :content => @comment2.content
  end
  # Test index  GET  /:locale/works/:work_id/chapters/:chapter_id/comments  (named path: work_chapter_comments)
  def test_work_chapter_comments_path
    create_comments
    get :index, :work_id => @work.id, :chapter_id => @chapter1.id, :show_comments => true
    assert_response :success
    assert_not_nil assigns(:comments)
    assert_tag :tag => 'p', :content => 'first comment'
    assert_no_tag :tag => 'p', :content => 'second comment'
  end
  # Test new  GET  /:locale/chapters/:chapter_id/comments/new  (named path: new_chapter_comment)
  def test_new_chapter_comment_path
    create_comments
    get :new, :chapter_id => @chapter1.id
    assert_response :success
    assert_not_nil assigns(:commentable)
  end
  # Test new  GET  /:locale/comments/:comment_id/comments/new  (named path: new_comment_comment)
  # Test new  GET  /:locale/comments/new  (named path: new_comment)
  def test_new_comment_fail
    # Trying to create a new comment with nothing to comment on should result in an
    # error and being redirected back to the previous page
    @request.env['HTTP_REFERER'] = 'http://www.google.com/'
    get :new
    assert_response :redirect
    assert !flash[:error].blank?
  end
  # Test new  GET  /:locale/works/:work_id/chapters/:chapter_id/comments/new  (named path: new_work_chapter_comment)
  def test_new_work_chapter_comment_path
    create_comments
    get :new, :work_id => @work.id, :chapter_id => @chapter1.id
    assert_response :success
    assert_not_nil assigns(:commentable)
  end
  # Test reject  PUT  /:locale/comments/:id/reject  (named path: reject_comment)
  # Test show  GET  /:locale/chapters/:chapter_id/comments/:id  (named path: chapter_comment)
  def test_chapter_comment_path
    create_comments
    get :show, :chapter_id => @chapter1.id, :id => @comment1.id
    assert_tag :tag => 'p', :content => 'first comment'
    assert_tag :tag => 'p', :content => 'first child'
    assert_no_tag :tag => 'p', :content => 'second comment'
  end
  # Test show  GET  /:locale/comments/:id  (named path: comment)
  def test_comment_path
    create_comments
    get :show, :id => @comment1.id
    assert_response :success
    assert_tag :tag => 'p', :content => @comment1.content
    assert_no_tag :tag => 'p', :content => @comment2.content
    assert_tag :tag => 'p', :content => @child1.content
  end
  # Test show  GET  /:locale/works/:work_id/chapters/:chapter_id/comments/:id  (named path: work_chapter_comment)
  def test_work_chapter_comment_path
    create_comments
    get :show, :work_id => @work.id, :chapter_id => @chapter1.id, :id => @comment1.id
    assert_response :success
    assert_tag :tag => 'p', :content => 'first comment'
  end
  # Test update  PUT  /:locale/chapters/:chapter_id/comments/:id
  def test_update_chapter_comment
    create_comments
    @request.session[:user] = @user
    put :update, :chapter_id => @chapter1.id,
                 :id => @comment2.id,
                 :pseud_id => @pseud.id,
                 :comment => { :content => 'more content' }
    @comment2.reload
    assert_equal 'more content', @comment2.content
  end
  # Test update  PUT  /:locale/comments/:comment_id/comments/:id
  # Test update  PUT  /:locale/comments/:id
  def test_update_comment_comment
    create_comments
    @request.session[:user] = @user
    put :update, :id => @child1.id, :comment => { :content => 'new content' }
    @child1.reload
    assert_equal 'new content', @child1.content
  end
  # Test update  PUT  /:locale/works/:work_id/chapters/:chapter_id/comments/:id
  def test_update_work_chapter_comment
    create_comments
    @request.session[:user] = @user
    put :update, :work_id => @work.id,
                 :chapter_id => @chapter1.id,
                 :id => @comment2.id,
                 :comment => { :content => 'new content' }
    @comment2.reload
    assert_equal 'new content', @comment2.content
  end
  # Test update  PUT  /:locale/works/:work_id/chapters/:chapter_id/comments/:id
  def test_update_work_chapter_comment_fail_because_of_child
    create_comments
    @request.env['HTTP_REFERER'] = 'http://www.google.com/'
    @request.session[:user] = @user
    put :update, :work_id => @work.id,
                 :chapter_id => @chapter1.id,
                 :id => @comment1.id,
                 :comment => { :content => 'new content' }
    assert_redirected_to 'http://www.google.com/'
  end
end
