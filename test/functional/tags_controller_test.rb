require File.dirname(__FILE__) + '/../test_helper'

class TagsControllerTest < ActionController::TestCase
  context "on GET with :index" do
    setup do
      get :index, :locale => 'en'
    end
    should_respond_with :success
    should_render_template :index
    should_assign_to :tags
  end

  context "on GET with :new" do
    # TODO restricted to tag_wrangler
    setup do
      get :new, :locale => 'en'
    end
    should_respond_with :success
    should_render_template :new
    should_render_a_form
    should_assign_to :tag
  end

  context "on POST with :create" do
    # TODO restricted to tag_wrangler
    setup do
      @name = random_phrase
      put :create, :locale => 'en', :tag => {"name" => @name}
    end
    should_redirect_to 'tag_relationships_path'
    should_set_the_flash_to /successfully created/
    should_assign_to :tag
    should "create the tag" do
      assert Tag.find_by_name(@name)
    end
  end
  
  context "on POST with :create with error" do
    # TODO restricted to tag_wrangler
    setup do
      put :create, :locale => 'en', :tag => {"name" => ""}
    end
    should_render_template "new"
    should_render_a_form
    should_not_set_the_flash
    should_assign_to :tag
  end
  
  context "on GET with :show of a tag" do
    setup do
      @tag = create_tag
      get :show, :id => @tag.id, :locale => 'en'
    end
    should_respond_with :success
    should_assign_to :tag
    should_render_template :show
    should_assign_to :tags
    should_assign_to :works
    should_assign_to :bookmarks
    should_assign_to :ambiguous
  end

  context "a tag which tags a work" do
    setup do
      @tag = create_tag
      @work = create_work
      @work.update_attribute(:posted, true)
      tagging = create_tagging(:taggable => @work, :tag => @tag)  
    end
    context "on GET with :show" do
      setup do
        get :show, :id => @tag.id, :locale => 'en'
      end
      should_assign_to :works
      should "assign the work" do
        assert assigns(:works).include?(@work)
      end
    end
    context "which is restricted" do
      setup do
        @work.update_attribute(:restricted, true)
      end
      context "when not logged in" do
        setup do
          get :show, :id => @tag.id, :locale => 'en'
        end
        should "not assign the work" do
          assert !assigns(:works).include?(@work)
        end
      end
      context "when logged in" do
        setup do
          @user = create_user
          assert @request.session[:user] = @user
          get :show, :id => @tag.id, :locale => 'en'
        end
        should "be visible to a user" do
          assert assigns(:works).include?(@work)
        end
      end
    end
  end
  context "a tag which tags a bookmark" do
    setup do
      @tag = create_tag
      @bookmark = create_bookmark
      @bookmark.bookmarkable.update_attribute(:posted, true)
      tagging = create_tagging(:taggable => @bookmark, :tag => @tag) 
      @tag.reload
    end
    context "on GET with :show" do
      setup do
        get :show, :id => @tag.id, :locale => 'en'
      end
      should_respond_with :success
      should_assign_to :bookmarks
      should "assign the bookmark" do
        assert assigns(:bookmarks).include?(@bookmark)
      end
    end
    context "which is private" do
      setup do
        @bookmark.update_attribute(:private, true)
      end
      context "when not logged in" do
        setup do
          get :show, :id => @tag.id, :locale => 'en'
        end
        should "not assign the bookmark" do
          assert !assigns(:bookmarks).include?(@bookmark)
        end
      end
      context "when logged in as someone else" do
        setup do
          assert @request.session[:user] = create_user
          get :show, :id => @tag.id, :locale => 'en'
        end
        should "not assign the bookmark" do
          assert !assigns(:bookmarks).include?(@bookmark)
        end
      end
      context "when logged in as the owner" do
        setup do
          assert @request.session[:user] = @bookmark.user
          get :show, :id => @tag.id, :locale => 'en'
        end
        should "assign the bookmark" do
          assert assigns(:bookmarks).include?(@bookmark)
        end
      end
    end
  end
end
