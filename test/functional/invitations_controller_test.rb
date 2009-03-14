require File.dirname(__FILE__) + '/../test_helper'

class InvitationsControllerTest < ActionController::TestCase
  context "when not logged in" do
    setup do
      get :new, :locale => 'en'
    end
    should_redirect_to("login path") {login_path}
    should_set_the_flash_to /logged in/
  end

  context "when logged in with an invitation limit of zero" do
    setup do
      @user = new_user
      @user.save(false)
      @user.update_attribute(:invitation_limit, 0)
      @request.session[:user] = @user
      get :new, :locale => 'en'
    end
    should_redirect_to("the user's path") {user_path(@user)}
    should_set_the_flash_to /Sorry/
  end

  context "when logged in with an invitation limit greater than zero" do
    setup do
      @user = new_user
      @user.save(false)
      @request.session[:user] = @user
      get :new, :locale => 'en'
    end
    context "when viewing the new invitation page" do
      setup do
        get :new, :locale => 'en'
      end
      should_assign_to :invitation
      should_render_template :new
    end
    context "when creating a new tag invitation" do
      setup do
        @email = 'example@example.com'
        post :create, :invitation => { :recipient_email => @email, :sender => @user }, :locale => 'en'
      end
      should "create the invitation" do
        assert Invitation.find_by_recipient_email(@email)
      end
      should_redirect_to("the user's path") {user_path(@user)}
    end

  end
end
