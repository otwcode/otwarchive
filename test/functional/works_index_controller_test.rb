require 'test_helper'

# FIXME needs *lots* more test cases
class WorksIndexControllerTest < ActionController::TestCase
  tests WorksController

  context "a database with a restricted and an unrestricted work" do
    setup do
      @work1 = create_work(:revised_at => 1.minute.ago)
      @work1.add_default_tags
      @work1.update_attribute(:posted, true)
      @work2 = create_work(:restricted => true)
      @work2.add_default_tags
      @work2.update_attribute(:posted, true)
    end
    context "if you are not logged in" do
      setup do
        get :index, :locale => 'en'
      end
      should_render_template :index
      should_assign_to(:works) {[@work1]}
    end
    context "when logged in" do
      setup do
        @user = create_user
        @request.session[:user] = @user
        get :index, :locale => 'en'
      end
      should_render_template :index
      should_assign_to(:works) {[@work2, @work1]}
    end
  end

end
