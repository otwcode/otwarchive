require File.dirname(__FILE__) + '/../test_helper'

class WorksDraftsControllerTest < ActionController::TestCase
  tests WorksController

  # drafts
  context "try to view drafts" do
    setup {@user = create_user}
    context "when not logged in" do
       setup { get :drafts, :locale => 'en', :user_id => @user.login }
       should_redirect_to 'new_session_path(:restricted => true)'      
    end
    context "when not your drafts" do
      setup do
        @another_user = create_user
        @request.session[:user] = @another_user
        get :drafts, :locale => 'en', :user_id => @user.login
      end
      should_set_the_flash_to /your own drafts/
      should_redirect_to 'user_path(@another_user)'      
    end
    context "when you have none" do
      setup do
        @request.session[:user] = @user
        get :drafts, :locale => 'en', :user_id => @user.login
      end
      should_render_template 'drafts'
      should_assign_to :works, :equal => '[]'
    end
    context "when you have one" do
      setup do
        @work = create_work(:authors => [@user.default_pseud])
        @request.session[:user] = @user
        get :drafts, :locale => 'en', :user_id => @user.login
      end
      should_render_template 'drafts'
      should_assign_to :works, :equal => '[@work]'
    end
    context "when you have an old one" do
      setup do
        @work = create_work(:authors => [@user.default_pseud], :created_at => 2.weeks.ago)
        @request.session[:user] = @user
        get :drafts, :locale => 'en', :user_id => @user.login
      end
      should_render_template 'drafts'
      should_assign_to :works, :equal => '[]'
    end
  end
  
end
