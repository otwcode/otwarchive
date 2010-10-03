require 'test_helper'

class ProfileControllerTest < ActionController::TestCase
  # not technically the profile controller, but split up here
  # so the users controller tests aren't so huge
  tests UsersController
  
  # TODO: REWRITE WITHOUT FORM_TEST_HELPER CODE

  # context "on PUT to :update self with email that is" do
  #   setup do
  #     @old_email = random_email
  #     assert @old_email != @new_email
  #     assert @user = create_user(:email => @old_email)
  #     assert @request.session[:user] = @user
  #     get :edit, :locale => 'en', :id => @user.login
  #   end
  #   context "valid" do
  #     setup do
  #       @new_email = random_email
  #       form = select_form 'edit_user_' + @user.id.to_s
  #       form.user.email=@new_email
  #       assert form.submit
  #     end
  #     should "make the change" do
  #       @user.reload
  #       assert_equal @new_email, @user.email
  #     end
  #     should_set_the_flash_to /success/
  #     should_redirect_to("the user's profile") {user_profile_path(@user)}
  #   end
  #   context "invalid" do
  #     setup do
  #       @new_email = String.random
  #       form = select_form 'edit_user_' + @user.id.to_s
  #       form.user.email=@new_email
  #       assert form.submit
  #     end
  #     should "not make the change" do
  #       @user.reload
  #       assert_not_equal @new_email, @user.email
  #     end
  #     should "have email error message" do
  #      assert_tag :div, :content => /valid/, :attributes => { :id => 'error' }
  #     end
  #     should_render_template :edit
  #   end
  #   context "someone else's" do
  #     setup do
  #       @new_email = create_user.email
  #       form = select_form 'edit_user_' + @user.id.to_s
  #       form.user.email=@new_email
  #       assert form.submit
  #     end
  #     should "not make the change" do
  #       @user.reload
  #       assert_not_equal @new_email, @user.email
  #     end
  #     should "have email message" do
  #      assert_tag :div, :content => /already being used/, :attributes => { :id => 'error' }
  #     end
  #     should_render_template :edit
  #   end
  # end
  # 
  # context "on PUT to :update self to password" do
  #   setup do
  #     @old_password = String.random
  #     assert @user = create_user(:password => @old_password, :password_confirmation => @old_password)
  #     assert @request.session[:user] = @user
  #     get :edit, :locale => 'en', :id => @user.login
  #   end
  #   context "which is valid" do
  #     setup do
  #       @new_password = String.random
  # 
  #       form = select_form 'edit_user_' + @user.id.to_s
  # 
  #       form.check.password_check=@old_password
  #       form.user.password=@new_password
  #       form.user.password_confirmation=@new_password
  # 
  #       assert form.submit
  #     end
  #     should_set_the_flash_to /success/
  #     should_redirect_to("the user's profile") {user_profile_path(@user)}
  #   end
  #   context "with no password check" do
  #     setup do
  #       @new_password = String.random
  # 
  #       form = select_form 'edit_user_' + @user.id.to_s
  # 
  #       form.user.password=@new_password
  #       form.user.password_confirmation=@new_password
  # 
  #       assert form.submit
  #     end
  #     should_set_the_flash_to /failed/
  #     should_render_template :edit
  #   end
  #   context "with password mismatch" do
  #     setup do
  #       form = select_form 'edit_user_' + @user.id.to_s
  # 
  #       form.check.password_check=@old_password
  #       form.user.password=String.random
  #       form.user.password_confirmation=String.random
  # 
  #       assert form.submit
  #     end
  #     should "have error message" do
  #      assert_tag :div, :content => /match/, :attributes => { :id => 'error' }
  #     end
  #     should_render_template :edit
  #   end
  # end
  # 
  # context "on PUT to :update self with title and location" do
  #   setup do
  #     assert @user = create_user
  #     assert @request.session[:user] = @user
  #     get :edit, :locale => 'en', :id => @user.login
  #     form = select_form 'edit_user_' + @user.id.to_s
  #     form.profile_attributes.title = "A New Title"
  #     form.profile_attributes.location = "Somewhere"
  #     assert form.submit
  #   end
  #   should "have a title now" do
  #     assert :p, :content => "A New Title"
  #   end
  #   should "have a location now" do
  #     assert :p, :content => "Somewhere"
  #   end
  # end
  # 
  # context "on PUT to :update self with new age" do
  #   setup do
  #     assert @user = create_user(:profile => @profile)
  #     assert @user.profile.update_attribute(:date_of_birth, '1960-11-09')
  #     assert @request.session[:user] = @user
  #     get :edit, :locale => 'en', :id => @user.login
  #   end
  #   context "greater than 13" do
  #     setup do
  #       form = select_form 'edit_user_' + @user.id.to_s
  #       form.profile_attributes["date_of_birth(3i)"] = "9"
  #       form.profile_attributes["date_of_birth(2i)"] = "11"
  #       form.profile_attributes["date_of_birth(1i)"] = "1950"
  #       assert form.submit
  #     end
  #     should "have new birthday" do
  #       assert :dd, :content => "1950-11-09", :attributes => { :id => 'birthday' }
  #     end
  #   end
  #   # note, this test will fail on the 31st of December
  #   context "less than 13" do
  #     setup do
  #       form = select_form 'edit_user_' + @user.id.to_s
  #       form.profile_attributes["date_of_birth(3i)"] = "31"
  #       form.profile_attributes["date_of_birth(2i)"] = "12"
  #       form.profile_attributes["date_of_birth(1i)"] = 13.years.ago.year.to_s
  #       assert form.submit
  #     end
  #     should "not have new birthday" do
  #       assert :dd, :content => "1960-11-09", :attributes => { :id => 'birthday' }
  #     end
  #   end
  # end
end
