# https://github.com/heartcombo/devise/wiki/How-To:-Test-controllers-with-Rails-(and-RSpec)

module LoginMacros
  def fake_login
    fake_login_known_user create(:user)
  end

  def fake_login_known_user(user)
    # The application expects users to have passed through the login form
    # and had the correct cookies set. We skip that in tests.
    allow(controller).to receive(:logout_if_not_user_credentials)

    @request.env["devise.mapping"] = Devise.mappings[:user]
    sign_in user, scope: :user
  end

  def fake_login_admin(admin)
    @request.env["devise.mapping"] = Devise.mappings[:admin]
    sign_in admin, scope: :admin
  end

  def fake_logout
    sign_out :admin
    sign_out :user
  end
end
