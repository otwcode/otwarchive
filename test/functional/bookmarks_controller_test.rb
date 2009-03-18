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
  end

  context "when indexing my own bookmarks" do
    setup do
      @user = create_user
      @pseud = @user.default_pseud
      @request.session[:user] = @user
      @bookmark = create_bookmark(:pseud => @pseud)
      get :index, :user_id => @user.login
    end

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

  context "when showing my own bookmark" do
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
end
