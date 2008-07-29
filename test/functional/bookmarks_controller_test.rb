require File.dirname(__FILE__) + '/../test_helper'

class BookmarksControllerTest < ActionController::TestCase
  context "when indexing all bookmarks" do
    setup do
      get :index, :locale => 'en'
    end
    should_respond_with :success
    should_render_template :index
    should_assign_to :bookmarks
  end

  context "when indexing a user's bookmarks" do
    setup do
      @user = create_user
      @bookmark = create_bookmark(:user => @user)
      get :index, :locale => 'en', :user_id => @user.login
    end
    
    should_assign_to :user
  end

  context "when indexing my own bookmarks" do
    setup do
      @user = create_user
      @request.session[:user] = @user 
      @bookmark = create_bookmark(:user => @user)
      get :index, :locale => 'en', :user_id => @user.login
    end
    
  end

  context "when showing a bookmark" do
    setup do
      @bookmark = create_bookmark
      @bookmark.bookmarkable.update_attribute(:posted, true)
      get :show, :locale => 'en', :id => @bookmark.id
    end
    should_respond_with :success
    should_render_template :show
    should_assign_to :bookmark
  end

  context "when showing my own bookmark" do
    setup do
      @user = create_user
      @bookmark = create_bookmark(:user => @user, :private => true)
      @bookmark.bookmarkable.update_attribute(:posted, true)
      @request.session[:user] = @user 
      get :show, :locale => 'en', :id => @bookmark.id
    end    
    should_respond_with :success
  end
  
  context "when showing a private bookmark, not my own" do
    setup do
      @user = create_user
      @request.session[:user] = @user 
      @bookmark = create_bookmark(:private => true)
      @bookmark.bookmarkable.update_attribute(:posted, true)
      @request.session[:user] = @user 
      get :show, :locale => 'en', :id => @bookmark.id
    end
    
    should_respond_with 403
  end
end
