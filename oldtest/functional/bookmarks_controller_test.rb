require 'test_helper'

class BookmarksControllerTest < ActionController::TestCase
# Index tests
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

#Show tests
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

# Destroy tests  
  context "try to destroy a bookmark" do
    setup do
      @user = create_user
      @pseud = @user.default_pseud
      @bookmark = create_bookmark(:pseud => @pseud)
    end
    context "when not logged in" do
      setup {delete :destroy, :id => @bookmark.id}
      should_redirect_to("the bookmark path") {bookmark_path(@bookmark)}
      should_set_the_flash_to /have permission/
    end
    context "when not your bookmark" do
      setup do
        @another_user = create_user
        @request.session[:user] = @another_user
        delete :destroy, :id => @bookmark.id
      end
      should_set_the_flash_to /have permission/
      should_redirect_to("the bookmark path") {bookmark_path(@bookmark)}
    end
    context "of your own" do
      setup do
        @request.session[:user] = @user
        delete :destroy, :id => @bookmark.id
      end
      should_redirect_to("the user's bookmarks path") {user_bookmarks_path(@user)}
      should "destroy the work" do
        assert_raises(ActiveRecord::RecordNotFound) { @bookmark.reload }
      end
    end
  end  

# Edit tests 
  context "when not logged in" do
    setup do
      @bookmark = create_bookmark
      get :edit, :id => @bookmark.id
    end
      should_set_the_flash_to /have permission/
      should_redirect_to("the login path") {new_session_path}
  end

  context "when logged in" do
    setup do
      @user = create_user
      @request.session[:user] = @user
    end

  context "when editing your own bookmark" do
    setup do
      @pseud = @user.default_pseud
      @bookmark = create_bookmark(:pseud => @pseud)
      get :edit, :id => @bookmark.id
    end
    should_respond_with :success
    should_render_template :edit
  end
end
 
end
