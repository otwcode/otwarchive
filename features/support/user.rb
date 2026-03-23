module UserHelpers
  def find_or_create_new_user(login, password, activate: true)
    user = User.find_by(login: login)
    if user.blank?
      params = { login: login, password: password }
      params[:confirmed_at] = nil unless activate
      user = FactoryBot.create(:user, params)
    else
      user.skip_password_change_notification!
      user.password = password
      user.password_confirmation = password
      user.save
    end
    user
  end

  # Like find_or_create_new_user above, but with fewer options, and it doesn't
  # invalidate the session for any pre-existing users (because it's not setting
  # the password).
  def ensure_user(login)
    user = User.find_by(login: login)
    return user unless user.nil?

    FactoryBot.create(:user, login: login)
  end
end

World(UserHelpers)
