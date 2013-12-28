require 'test_helper'

class AbuseReportsControllerTest < ActionController::TestCase

  context "on GET to :new" do
    context "in general" do
      setup do
        @url = random_url(ArchiveConfig.APP_URL)
        @request.env["HTTP_REFERER"] = @url
        get :new, :locale => 'en'
      end
      should_assign_to :abuse_report
      should_respond_with :success
      should_render_template :new
      should "preset url" do
        assert_equal @url, assigns(:abuse_report).url
      end
    end

    context "when logged in" do
      setup do
        @user = create_user
        @request.session[:user] = @user
        get :new, :locale => 'en'
      end

      should "preset user's email" do
        assert_equal @user.email, assigns(:abuse_report).email
      end
    end
  end

  context "on POST to :create" do
    context "on failure" do
      setup do
        put :create, :locale => 'en', :abuse_report=>{"email"=>"filled in"}
      end
      should_assign_to :abuse_report
      should "remember filled in fields" do
        assert_equal "filled in", assigns(:abuse_report).email
      end
      should_render_template :new
      should "show validation errors" do
        assert_tag :tag => "div", :attributes => {:id => "error"}
      end
    end

    context "on success" do
      setup do
        put :create, :locale => 'en', :abuse_report =>
          {"url"=>ArchiveConfig.APP_URL,
           "comment"=>"a comment",
           "email"=>"user@google.com"}
      end
      should_redirect_to('the root path') { '/' }
    end

  end
end


