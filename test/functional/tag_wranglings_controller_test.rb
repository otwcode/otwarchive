require 'test_helper'

class TagWranglingsControllerTest < ActionController::TestCase
  context "when not logged in" do
    setup do
      get :index, :locale => 'en'
    end
    should_redirect_to('the new session') {new_session_path}
    should_set_the_flash_to /log in/
  end

  context "when logged in" do
    setup do
      @user = create_user
      @request.session[:user] = @user
      get :index, :locale => 'en'
    end
    should_redirect_to("the user's path") {user_path(@user)}
    should_set_the_flash_to /access/
  end

  context "when logged in as a tag_wrangler" do
    setup do
      @user = create_user
      @user.is_tag_wrangler
      @request.session[:user] = @user
    end
    context "when looking at tag wranglings" do
      setup do
        get :index, :locale => 'en'
      end
      should_render_template :index
    end
  end
end
