module UserHelpers
  def find_or_create_user(login, password)
    user = User.find_by_login(login)
    if user.blank?
      user = FactoryGirl.create(:user, { login: login, password: password })
      user.activate
    else
      user.password = password
      user.password_confirmation = password
      user.save
    end
    user
  end
end

World(UserHelpers)
