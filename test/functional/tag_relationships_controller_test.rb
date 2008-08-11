require File.dirname(__FILE__) + '/../test_helper'

class TagRelationshipsControllerTest < ActionController::TestCase
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
    context "when looking at tag relationships" do
      setup do
        get :index, :locale => 'en'
      end
      should_render_template :index
      should_assign_to :tag_relationships
    end
    context "when looking at a tag relationship" do
      setup do
        @tag_relationship = create_tag_relationship
        get :show, :locale => 'en', :id => @tag_relationship.id
      end
      should_assign_to :tag_relationship
      should_render_template :show
    end
    context "when building a new tag relationships" do
      setup do
        get :new, :locale => 'en'
      end
      should_assign_to :tag_relationship
      should_render_template :new
    end
    context "when creating a new tag relationships" do
      setup do
        @name = random_word
        post :create, :tag_relationship => { :name => @name, :verb_phrase => random_phrase, :distance => rand(4) }
      end
      should "create the tag relationship" do
        assert TagRelationship.find_by_name(@name)
      end
    end
    context "when editing a tag relationships" do
      setup do
        @tag_relationship = create_tag_relationship
        get :edit, :locale => 'en', :id => @tag_relationship.id
      end
      should_assign_to :tag_relationship
      should_render_template :edit
    end
    context "when updating a tag relationships" do
      setup do
        @tag_relationship = create_tag_relationship
        @new_phrase = random_phrase
        put :update, :id => @tag_relationship.id, :tag_relationship => { :verb_phrase => @new_phrase }, :locale => 'en'
      end
      should "update the tag relationship" do
        assert_equal @new_phrase, TagRelationship.find(@tag_relationship.id).verb_phrase
      end
    end
    context "when destroying a tag relationships" do
      setup do
        @tag_relationship = create_tag_relationship
        delete :destroy, :id => @tag_relationship.id, :locale => 'en'
      end
      should "delete the tag relationship" do
        assert_raises(ActiveRecord::RecordNotFound) { @tag_relationship.reload }
      end
    end
  end
end
