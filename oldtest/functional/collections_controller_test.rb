require 'test_helper'

class CollectionsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:collections)
  end
  
  
  context "when not logged in" do
    context "and trying to create a new collection" do
      setup do
        get :new
      end
      should "not display a form" do
         assert_select "form", false
      end
      should_set_the_flash_to /have permission/
      should_redirect_to("the login page") {new_session_path}
    end
    context "and trying to edit a collection" do
      setup do
        @collection = create_collection
        get :edit, :id => @collection.name
      end
      should "not display a form" do
         assert_select "form", false
      end
      should_set_the_flash_to /have permission/
      should_redirect_to("the login page") {new_session_path}
    end
  end

  context "when logged in" do
    setup do
      @user = create_user
      @request.session[:user] = @user
    end
    context "and getting :new" do
      setup do
        get :new
      end
      should "display a form" do
        assert_select "form", true
      end
      should_respond_with :success
      should_render_template :new
    end
    context "and creating a collection" do
      setup do
        @collection_name = String.random
        post :create, :collection => {:name => @collection_name, :title => random_phrase}, :owner_pseuds => [@user.default_pseud]
        @collection = Collection.find_by_name(@collection_name)
      end
      should_assign_to :collection
      should_redirect_to("the new collection") {collection_path(@collection)}
    end
    context "and editing a collection" do
      setup do
        @collection = create_collection
      end
      context "that the user does not own" do
        setup do 
          get :edit, :id => @collection.name
        end
        should "not display a form" do
          assert_select "form", false
        end
        should_redirect_to("the user's path") {user_path(@user)}
        should_set_the_flash_to /have permission/
      end
      context "that the user owns" do
        setup do
          @owner = create_collection_participant(:collection => @collection, :pseud => @user.default_pseud, :participant_role => CollectionParticipant::OWNER)
          @collection.reload
          get :edit, :id => @collection.name
        end
        should "display a form" do
          assert_select "form", true
        end
        should_respond_with :success
        should_render_template :edit
      end
    end
  end

end
