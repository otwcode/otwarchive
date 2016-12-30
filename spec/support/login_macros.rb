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

  def fake_login_admin(admin)
    @current_admin = admin
    allow(controller).to receive(:logged_in_as_admin?).and_return(true)
    allow(controller).to receive(:current_admin).and_return(@current_admin)
  end

  def it_redirects_to(path)
    expect(response).to have_http_status(:redirect)
    expect(response).to redirect_to path
  end
end
