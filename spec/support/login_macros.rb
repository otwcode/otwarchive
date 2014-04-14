module LoginMacros

  def fake_login
    # Stub out the current_user method
    @current_user = FactoryGirl.create(:user)
    controller.stub!(:logged_in?).and_return(true)
    controller.stub!(:current_user).and_return(@current_user)
    controller.stub!(:logout_if_not_user_credentials).and_return(nil)
  end
  
end