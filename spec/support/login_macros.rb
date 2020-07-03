module LoginMacros

  def fake_login
    # Stub out the current_user method
    @current_user = FactoryBot.create(:user)
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
    @request.env["devise.mapping"] = Devise.mappings[:admin]
    @current_admin = admin
    allow(controller).to receive(:logged_in_as_admin?).and_return(true)
    allow(controller).to receive(:current_admin).and_return(@current_admin)
    sign_in admin, scope: :admin
  end

  def fake_logout
    @current_admin = nil
    @current_user = nil
    allow(controller).to receive(:logged_in_as_admin?).and_return(false)
    allow(controller).to receive(:current_admin).and_return(@current_admin)
    allow(controller).to receive(:logged_in?).and_return(false)
    allow(controller).to receive(:current_user).and_return(@current_user)
  end
end
