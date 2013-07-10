require 'test_helper'

class TranslationNotesControllerTest < ActionController::TestCase
  # context "when not logged in" do
  #   setup do
  #     get :index, :locale => 'en'
  #   end
  #   should_redirect_to('the new session') {new_session_path}
  #   should_set_the_flash_to /log in/
  # end
  # 
  # context "when logged in" do
  #   setup do
  #     @user = create_user
  #     @request.session[:user] = @user
  #     get :index, :locale => 'en'
  #   end
  #   should_redirect_to("the user's path") {user_path(@user)}
  #   should_set_the_flash_to /access/
  # end
  # 
  # context "when logged in as a translator" do
  #   setup do
  #     @user = create_user
  #     @user.is_translator_for Locale.default
  #     @request.session[:user] = @user
  #   end
  #   context "when looking at translation notes" do
  #     setup do
  #       get :index, :locale => 'en'
  #     end
  #     should_render_template :index
  #   end
  #   context "when viewing the new translation notes page" do
  #     setup do
  #       get :new
  #     end
  #     should_render_template :new
  #   end
  # end
end
