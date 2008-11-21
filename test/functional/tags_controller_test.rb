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
  context "when logged out, should not be able to access new tags page" do
    setup do
      get :new, :locale => 'en'
    end
    should_redirect_to "{:controller => :session, :action => 'new'}"
    should_set_the_flash_to /log in/  
  end
  
  context "when logged in as a non-tag-wrangler, should not be able to access new tags page" do
    setup do
      @user = create_user
      @request.session[:user] = @user
      get :new, :locale => 'en'
    end
    should_redirect_to "user_path(@user)"
    should_set_the_flash_to /permission/  
  end
  
  context "when logged in as a tag wrangler" do
    setup do
      @user = create_user
      @user.is_tag_wrangler
      @request.session[:user] = @user
    end
    context "on GET with :new" do
      # TODO restricted to tag_wrangler
      setup do
        @user = create_user
        @user.is_tag_wrangler
        @request.session[:user] = @user
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
        @name = random_phrase[1...ArchiveConfig.TAG_MAX]
        @type = "Freeform"
        put :create, :locale => 'en', :tag => {"name" => @name, "type" => @type}
      end
      should_redirect_to 'edit_tag_path(Tag.find_by_name(@name))'
      should_set_the_flash_to /successfully created/
      should_assign_to :tag
      should "create the tag" do
        assert Freeform.find_by_name(@name)
      end
    end
  
    context "on POST with :create with error" do
      # TODO restricted to tag_wrangler
      setup do
        put :create, :locale => 'en', :tag => {"name" => ""}
      end
      should_render_template "new"
      should_render_a_form
      should_set_the_flash_to /Please provide a category/
      should_assign_to :tag
    end
  end
end
