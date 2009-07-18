require File.dirname(__FILE__) + '/../test_helper'

class BookmarksControllerTest < ActionController::TestCase
  context "when indexing all bookmarks" do
    setup do
      get :index
    end
    should_respond_with :success
    should_render_template :index
    should_assign_to :bookmarks
  end

  context "when indexing a user's bookmarks" do
    setup do
      @user = create_user
      @pseud = @user.default_pseud
      @bookmark = create_bookmark(:pseud => @pseud)
      get :index, :user_id => @user.login
    end
    should_assign_to :user
    should_assign_to :bookmarks
    should_respond_with :success
    should_render_template :index    
  end

  context "when indexing my own bookmarks" do
    setup do
      @user = create_user
      @pseud = @user.default_pseud
      @request.session[:user] = @user
      @bookmark = create_bookmark(:pseud => @pseud)
      get :index, :user_id => @user.login
    end
    should_assign_to :user
    should_assign_to :bookmarks
    should_respond_with :success
    should_render_template :index    
  end
  
  context "when indexing bookmarks on a work" do
    setup do
      @work = create_work
      @bookmark = create_bookmark(:private => false)      
      @bookmark.bookmarkable = @work      
      @bookmark.bookmarkable.add_default_tags
      @bookmark.bookmarkable.update_attribute(:posted, true)
      get :index, :work_id => @bookmark.bookmarkable_id
    end
    should_respond_with :success
    should_render_template :index
    should_assign_to :bookmarks
  end  

  context "when showing a bookmark" do
    setup do
      @bookmark = create_bookmark
      @bookmark.bookmarkable.add_default_tags
      @bookmark.bookmarkable.update_attribute(:posted, true)
      get :show, :id => @bookmark.id
    end
    should_respond_with :success
    should_render_template :show
    should_assign_to :bookmark
  end

  context "when showing my own private bookmark" do
    setup do
      @user = create_user
      @pseud = @user.default_pseud
      @bookmark = create_bookmark(:pseud => @pseud, :private => true)
      @bookmark.bookmarkable.add_default_tags
      @bookmark.bookmarkable.update_attribute(:posted, true)
      @request.session[:user] = @user
      get :show, :id => @bookmark.id
    end
    should_respond_with :success
    should_render_template :show
    should_assign_to :bookmark    
  end

  context "when showing a private bookmark, not my own" do
    setup do
      @user = create_user
      @pseud = @user.default_pseud
      @request.session[:user] = @user
      @bookmark = create_bookmark(:private => true)
      @bookmark.bookmarkable.add_default_tags
      @bookmark.bookmarkable.update_attribute(:posted, true)
      @request.session[:user] = @user
      get :show, :id => @bookmark.id
    end
    should "have error" do
      assert flash.has_key?(:error)
    end
    should_redirect_to("the user's path") {user_path(@user)}
  end
  
  context "when showing my own bookmark hidden by an admin" do
    setup do
      @user = create_user
      @pseud = @user.default_pseud
      @bookmark = create_bookmark(:pseud => @pseud, :hidden_by_admin => true)
      @bookmark.bookmarkable.add_default_tags
      @bookmark.bookmarkable.update_attribute(:posted, true)
      @request.session[:user] = @user
      get :show, :id => @bookmark.id
    end
    should_respond_with :success
    should_render_template :show
    should_assign_to :bookmark    
  end
  
  context "when showing a bookmark, not my own, hidden by an admin" do
    setup do
      @user = create_user
      @pseud = @user.default_pseud
      @request.session[:user] = @user
      @bookmark = create_bookmark(:hidden_by_admin => true)
      @bookmark.bookmarkable.add_default_tags
      @bookmark.bookmarkable.update_attribute(:posted, true)
      @request.session[:user] = @user
      get :show, :id => @bookmark.id
    end
    should "have error" do
      assert flash.has_key?(:error)
    end
    should_redirect_to("the user's path") {user_path(@user)}
  end  
  
  context "when showing a bookmark on a restricted work to a user" do
    setup do
      @user = create_user
      @bookmark = create_bookmark
      @bookmark.bookmarkable.add_default_tags
      @bookmark.bookmarkable.update_attribute(:posted, true)
      @bookmark.bookmarkable.update_attribute(:restricted, true)
      @request.session[:user] = @user
      get :show, :id => @bookmark.id
    end
    should_respond_with :success
    should_render_template :show
    should_assign_to :bookmark    
  end
  
  context "when showing a bookmark on a restricted work when logged out" do
    setup do
      @bookmark = create_bookmark
      @bookmark.bookmarkable.add_default_tags
      @bookmark.bookmarkable.update_attribute(:posted, true)
      @bookmark.bookmarkable.update_attribute(:restricted, true)
      @request.session[:user] = nil
      get :show, :id => @bookmark.id
    end
    should "have error" do
      assert flash.has_key?(:error)
    end
  end    
 
end
