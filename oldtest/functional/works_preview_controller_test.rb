require 'test_helper'

class WorksPreviewControllerTest < ActionController::TestCase
  tests WorksController

  context "if you are not logged in" do
    setup do
      @work = create_work
      get :preview, :locale => 'en', :id => @work.id
    end
    should_redirect_to("new session") {new_session_url}
  end

  context "when logged in" do
    setup do
      @user = create_user
      @user.activate
      @request.session[:user] = @user
    end
    context "someone else's work" do
      setup do
        @work = create_work(:authors => [create_user.default_pseud])
        get :preview, :locale => 'en', :id => @work.id
      end
      should_redirect_to("the work's path") {work_path(@work)}
      should_set_the_flash_to /permission/
    end
    context "your own work" do
      setup do
        @work = create_work(:authors => [@user.default_pseud])
        get :preview, :locale => 'en', :id => @work.id
      end
      should_respond_with :success
      should_assign_to(:work) {@work}
      should_render_template :preview
    end
  end
end
