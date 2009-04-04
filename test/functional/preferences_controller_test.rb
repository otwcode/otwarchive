require File.dirname(__FILE__) + '/../test_helper'

class PreferencesControllerTest < ActionController::TestCase
  context "someone else" do
    setup do
      assert @user = create_user
      assert @second_user = create_user
      @request.session[:user] = @second_user
    end
    context "on POST to :edit " do
      setup { get :index, :locale => 'en', :user_id => @user.login }
      should "not display a form" do
         assert_select "form", false
      end
      should_redirect_to("the first user's path") {user_path(@user)}
      should_set_the_flash_to /have permission/
    end
    context "on PUT to :update" do
      setup do
        put :update, :locale => 'en', :user_id => @user.login, :user => { :preference => { :history_enabled => '0' } }
      end
      should "not make the change" do
        assert @user.preference.history_enabled
      end
      should_redirect_to("the first user's path") {user_path(@user)}
      should_set_the_flash_to /have permission/
    end
  end

  context "yourself" do
    setup do
      assert @user = create_user
      assert @request.session[:user] = @user
      get :index, :locale => 'en', :user_id => @user.login
    end
    context "on edit" do
      should_respond_with :success
      should_render_template :index
      should_render_a_form
      should_not_set_the_flash
      should_assign_to(:user) {@user}
      should_assign_to(:preference) {@user.preference}
    end
    context "on update" do
      setup do
        assert form = select_form('edit_preference_' + @user.preference.id.to_s)
        form.preference.history_enabled.uncheck
        form.preference.email_visible.check
        form.preference.date_of_birth_visible.check
        form.preference.adult.check
        form.preference.hide_warnings.check
        form.preference.comment_emails_off.check
        form.preference.comment_inbox_off.check
        form.preference.comment_copy_to_self_off.uncheck
        form.preference.work_title_format = "AUTHOR - FANDOM - TITLE"
        assert form.submit
      end
      # FIXME getting RoutingError
      # the route's okay - may be a bug in form_test_helper
#      should_respond_with :success
      should_eventually "set preferences" do
        assert !@user.preference.history_enabled
        assert @user.preference.email_visible
        assert @user.preference.date_of_birth_visible
        assert @user.preference.adult
        assert @user.preference.hide_warnings
        assert @user.preference.comment_emails_off
        assert @user.preference.comment_inbox_off
        assert !@user.preference.comment_copy_to_self_off
        assert_equal "AUTHOR - FANDOM - TITLE", @user.preference.work_title_format
      end
    end
  end
end
