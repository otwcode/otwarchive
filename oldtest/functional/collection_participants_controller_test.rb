require 'test_helper'

class CollectionParticipantsControllerTest < ActionController::TestCase

  context "with a collection" do
    setup do
      @collection = create_collection
      @request.env["HTTP_REFERER"] = root_path # to enable redirect_to :back
    end
    context "when trying to join while not logged in" do
      setup do
        get :join, :collection_id => @collection.name
      end
      should_redirect_to("login page") {new_session_path}
      should_set_the_flash_to /Please log in/
    end
    context "when logged in" do 
      setup do
        @user = create_user
        @request.session[:user] = @user
      end
      context "and joining an unmoderated collection" do
        setup do
          get :join, :collection_id => @collection.name
        end
        should_set_the_flash_to /You have applied/
        should "add the user as a non-posting participant" do
          assert @collection.user_is_participant?(@user)
          assert !@collection.user_is_posting_participant?(@user)
        end
      end
    end
  end
  
end
