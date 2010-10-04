require 'test_helper'

class InvitationsControllerTest < ActionController::TestCase
  context "when not logged in" do
    setup do
      @user = new_user
      get "user_invitations_path(@user)"
    end
    should_redirect_to("new session path") {new_session_path}
    should_set_the_flash_to /log in/
  end

  context "when logged in" do
    setup do
      @user = new_user
      @user.save(:validate => false)
      @user.update_attribute(:invitation_limit, 0)
      @request.session[:user] = @user
      get "user_invitations_path(@user)"
    end
  end
end
