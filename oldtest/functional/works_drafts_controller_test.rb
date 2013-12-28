require 'test_helper'

class WorksDraftsControllerTest < ActionController::TestCase
  tests WorksController

  # drafts
  context "try to view drafts" do
    setup {@user = create_user}
    context "when not logged in" do
       setup { get :drafts, :locale => 'en', :user_id => @user.login }
       should_redirect_to("new session") {new_session_url}
    end
    context "when not your drafts" do
      setup do
        @another_user = create_user
        @request.session[:user] = @another_user
        get :drafts, :locale => 'en', :user_id => @user.login
      end
      should_set_the_flash_to /your own drafts/
      should_redirect_to("another user's path") {user_path(@another_user)}
    end
    context "when you have none" do
      setup do
        @request.session[:user] = @user
        get :drafts, :locale => 'en', :user_id => @user.login
      end
      should_render_template 'drafts'
      should_assign_to(:works) {[]}
    end
    context "when you have one" do
      setup do
        @work = create_work(:authors => [@user.default_pseud])
        @work.fandoms = [create_fandom]
        @request.session[:user] = @user
        get :drafts, :locale => 'en', :user_id => @user.login
      end
      should_render_template 'drafts'
      should_assign_to(:works) {[@work]}
    end
    context "when you have an old one" do
      setup do
        @work = create_work(:authors => [@user.default_pseud], :created_at => 2.weeks.ago)
        @request.session[:user] = @user
        Work.purge_old_drafts
        get :drafts, :locale => 'en', :user_id => @user.login
      end
      should_render_template 'drafts'
      should_assign_to(:works) {[]}
    end
  end

end
