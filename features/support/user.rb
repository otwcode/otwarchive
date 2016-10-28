module UserHelpers
  def find_or_create_user(login, password, hidden)
    user = User.find_by_login(login)
    if user.blank?
      user = FactoryGirl.create(:user, { login: login, password: password })
      user.activate
    else
      user.password = password
      user.password_confirmation = password
      user.save
    end
    if hidden.present?
      user.preference.hide_warnings = true
      user.preference.hide_freeform = true
      user.preference.save
    end
    user
  end
end

World(UserHelpers)
