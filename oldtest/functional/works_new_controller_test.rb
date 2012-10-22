require 'test_helper'

class WorksNewControllerTest < ActionController::TestCase
  tests WorksController

  context "try to create a new work" do
    context "when not logged in" do
      setup do
        get :new, :locale => 'en'
      end
      should_redirect_to("new session") {new_session_url}
    end
    context "when logged in" do
      setup do
        @user = create_user
        @request.session[:user] = @user
      end
      context "basic new" do
        setup { get :new, :locale => 'en' }
        should_respond_with :success
        should_render_template :new
        should_assign_to :work
        should "not have unposted link" do
          assert_no_tag :tag => "li",  :attributes => {:id => "restore-link"}
        end
      end
      context "new with unposted" do
        setup do
          @work = create_work(:authors => [@user.default_pseud])
          get :new, :locale => 'en'
        end
        should "have unposted link" do
          assert_tag :tag => "li",  :attributes => {:id => "restore-link"}
        end
      end
      context "new with old unposted" do
        setup do
          @work = create_work(:authors => [@user.default_pseud], :created_at => 2.weeks.ago)
          Work.purge_old_drafts
          get :new, :locale => 'en'
        end
        should "not have unposted link" do
          assert_no_tag :tag => "li",  :attributes => {:id => "restore-link"}
        end
      end
      context "load unposted" do
        setup do
          @work = create_work(:authors => [@user.default_pseud])
          get :new, :locale => 'en', :load_unposted => true
        end
        should_render_template :edit
        should_assign_to(:work) {@work}
      end
      context "upload work" do
        setup do
          get :new, :locale => 'en', :import => true
        end
        should_render_template :new_import
      end
    end
  end
end
