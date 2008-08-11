require File.dirname(__FILE__) + '/../test_helper'

class TagCategoriesControllerTest < ActionController::TestCase
  context "when not logged in" do
    setup do
      get :index, :locale => 'en'
    end
    should_redirect_to 'root_path'
    should_set_the_flash_to /tag wranglers only/      
  end
  
  context "when logged in" do
    setup do
      @user = create_user
      @request.session[:user] = @user
      get :index, :locale => 'en'
    end
    should_redirect_to 'root_path'
    should_set_the_flash_to /tag wranglers only/      
  end

  context "when logged in as a tag_wrangler" do
    setup do
      @user = create_user
      @user.roles << Role.find_or_create_by_name("TagWrangler")
      @request.session[:user] = @user
    end
    context "when looking at tag categories" do
      setup do
        get :index, :locale => 'en'
      end
      should_render_template :index
      should_assign_to :tag_categories
    end
    context "when looking at a tag category" do
      setup do
        @tag_category = create_tag_category
        get :show, :locale => 'en', :id => @tag_category.id
      end
      should_assign_to :tag_category
      should_render_template :show
    end
    context "when building a new tag categories" do
      setup do
        get :new, :locale => 'en'
      end
      should_assign_to :tag_category
      should_render_template :new
    end
    context "when creating a new tag categories" do
      setup do
        @name = random_word
        post :create, :tag_category => { :name => @name }, :locale => 'en'
      end
      should "create the tag category" do
        assert TagCategory.find_by_name(@name)
      end
    end
    context "when editing a tag categories" do
      setup do
        @tag_category = create_tag_category
        get :edit, :locale => 'en', :id => @tag_category.id
      end
      should_assign_to :tag_category
      should_render_template :edit
    end
    context "when updating a tag categories" do
      setup do
        @tag_category = create_tag_category
        @new_phrase = random_phrase
        put :update, :id => @tag_category.id, :tag_category => { :display_name => @new_phrase }, :locale => 'en'
      end
      should "update the tag category" do
        assert_equal @new_phrase, TagCategory.find(@tag_category.id).display_name
      end
    end
    context "when destroying a tag categories" do
      setup do
        @tag_category = create_tag_category
        delete :destroy, :id => @tag_category.id, :locale => 'en'
      end
      should "delete the tag category" do
        assert_raises(ActiveRecord::RecordNotFound) { @tag_category.reload }
      end
    end
  end
end
