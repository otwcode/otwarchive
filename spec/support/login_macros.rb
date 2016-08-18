module LoginMacros

  def fake_login
    # Stub out the current_user method
    @current_user = FactoryGirl.create(:user)
    allow(controller).to receive(:logged_in?).and_return(true)
    allow(controller).to receive(:current_user).and_return(@current_user)
    allow(controller).to receive(:logout_if_not_user_credentials).and_return(nil)
  end
  
  def fake_login_known_user(user)
    @current_user = user
    allow(controller).to receive(:logged_in?).and_return(true)
    allow(controller).to receive(:current_user).and_return(@current_user)
    allow(controller).to receive(:logout_if_not_user_credentials).and_return(nil)
  end
end