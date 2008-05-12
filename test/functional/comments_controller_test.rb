require File.dirname(__FILE__) + '/../test_helper'

class CommentsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index, :locale => 'en'
    assert_response :success
    assert_not_nil assigns(:comments)
    assert_tag :tag => 'p', :content => comments(:basic_comment).content
    assert_tag :tag => 'p', :content => comments(:comment_on_comment).content
    assert_tag :tag => 'p', :content => comments(:comment_on_chapter1).content
    assert_tag :tag => 'p', :content => comments(:comment_on_chapter2).content
  end
  
  # The index of comments on a comment should go into that comment's thread,
  # and display only the comments on it, NOT the comment itself
  def test_should_get_index_on_comment
    get :index, :locale => 'en', :comment_id => comments(:basic_comment).id
    assert_response :success
    assert_not_nil assigns(:comments)
    assert_no_tag :tag => 'p', :content => comments(:basic_comment).content
    assert_tag  :tag => 'p', :content => comments(:comment_on_comment).content
    assert_no_tag :tag => 'p', :content => comments(:comment_on_chapter2).content
  end
  
  # The list of comments on a work should aggregate together all the comments 
  # from all its chapter. 
  def test_should_get_index_on_work
    get :index, :locale => 'en', :work_id => works(:basic_work).id
    assert_response :success
    assert_not_nil assigns(:comments)
    assert_tag :tag => 'p', :content => comments(:comment_on_chapter1).content
    assert_tag  :tag => 'p', :content => comments(:comment_on_comment).content
    assert_tag :tag => 'p', :content => comments(:comment_on_chapter2).content
  end
  
  # The list of comments on the chapter should give us the comments on this 
  # chapter and their comments, and no others. 
  def test_should_get_index_on_chapter
    get :index, :locale => 'en', :work_id => works(:basic_work).id, :chapter_id => chapters(:basic_chapter).id
    assert_response :success
    assert_not_nil assigns(:comments)
    assert_tag :tag => 'p', :content => comments(:comment_on_chapter1).content
    assert_tag  :tag => 'p', :content => comments(:comment_on_comment).content
    assert_no_tag :tag => 'p', :content => comments(:comment_on_chapter2).content
  end
  
  def test_should_not_get_new
    # Trying to create a new comment with nothing to comment on should result in an 
    # error and being redirected back to the previous page
    @request.env['HTTP_REFERER'] = 'http://www.google.com/'
    get :new, :locale => 'en'
    assert_response :redirect
    assert !flash[:error].blank?
  end

  def test_should_get_new_on_work
    get :new, :locale => 'en', :work_id => works(:basic_work).id
    assert_response :success
    assert_not_nil assigns(:commentable)
  end
  
  def test_should_get_new_on_chapter
    get :new, :locale => 'en', :work_id => works(:basic_work).id, :chapter_id => chapters(:basic_chapter).id
    assert_response :success
    assert_not_nil assigns(:commentable)
  end

  def test_should_get_new_on_comment
    get :new, :locale => 'en', :comment_id => comments(:basic_comment).id
    assert_response :success
    assert_not_nil assigns(:commentable)
  end

  def test_should_not_create_comment_without_commentable
    @request.env['HTTP_REFERER'] = 'http://www.google.com/'
    assert_no_difference('Comment.count') do
      post :create, :locale => 'en', :comment => { :content => 'foo', :name => 'Someone', :email => 'someone@someplace.org' }
    end
    assert !flash[:error].blank?
    assert_response :redirect

    login_as_user(:basic_user)
    assert_no_difference('Comment.count') do
      post :create, :locale => 'en', :comment => { :content => 'foo' }
    end
    assert !flash[:error].blank?
    assert_response :redirect
  
  end
  
  def test_should_create_comment_on_work
    assert_difference('Comment.count') do
      post :create, :locale => 'en', :work_id => works(:basic_work).id, :comment => { :content => 'foo', :name => 'Someone', :email => 'someone@someplace.org' }
    end    
    assert_redirected_to work_path(:locale => 'en', :id => works(:basic_work).id)
  end
  
  def test_should_create_comment_on_chapter
    assert_difference('Comment.count') do
      post :create, :locale => 'en', 
                    :work_id => works(:basic_work).id, 
                    :chapter_id => chapters(:basic_chapter).id, 
                    :comment => { :content => 'foo', :name => 'Someone', :email => 'someone@someplace.org' }
    end    
    assert_redirected_to work_path(:locale => 'en', :id => works(:basic_work).id)
  end

  def test_should_create_comment_on_comment
    assert_difference('Comment.count') do
      post :create, :locale => 'en', 
                    :comment_id => comments(:basic_comment).id, 
                    :comment => { :content => 'foo', :name => 'Someone', :email => 'someone@someplace.org' }
    end    
    assert_redirected_to work_path(:locale => 'en', :id => works(:basic_work).id)
  end

  # should display the comment with any comments made on it
  def test_should_show_comment
    get :show, :locale => 'en', :id => comments(:basic_comment).id
    assert_response :success
    assert_tag :tag => 'p', :content => comments(:basic_comment).content
    assert_tag  :tag => 'p', :content => comments(:comment_on_comment).content
    assert_no_tag :tag => 'p', :content => comments(:comment_on_chapter2).content
  end
  
  def test_should_get_edit
    get :edit, :locale => 'en', :id => comments(:basic_comment).id
    assert_response :success
  end
  
  def test_should_update_comment
    put :update, :locale => 'en', :id => comments(:basic_comment).id, :comment => { }
    assert_redirected_to comment_path(assigns(:comment))
  end
  
  def test_should_destroy_comment
    assert_difference('Comment.count', -1) do
      delete :destroy, :locale => 'en', :id => comments(:basic_comment).id
    end
    
    assert_redirected_to comments_path
  end
end
