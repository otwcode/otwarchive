require 'test_helper'

class WorksDestroyControllerTest < ActionController::TestCase
  tests WorksController

  context "try to destroy a work" do
    setup do
      @user = create_user
      @work = create_work(:authors => [@user.default_pseud])
    end
    context "when not logged in" do
      setup {delete :destroy, :locale => 'en', :id => @work.id}
      should_redirect_to("the work path") {work_path(@work)}
      should_set_the_flash_to /have permission/
    end
    context "when not your work" do
      setup do
        @another_user = create_user
        @request.session[:user] = @another_user
        delete :destroy, :locale => 'en', :id => @work.id
      end
      should_set_the_flash_to /have permission/
      should_redirect_to("the work path") {work_path(@work)}
    end
    context "of your own" do
      setup do
        @request.session[:user] = @user
        delete :destroy, :locale => 'en', :id => @work.id
      end
      should_redirect_to("the user's works path") {user_works_path(@user)}
      should "destroy the work" do
        assert_raises(ActiveRecord::RecordNotFound) { @work.reload }
      end
    end
  end

end
