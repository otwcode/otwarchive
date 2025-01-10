module UserHelpers
  def find_or_create_new_user(login, password, activate: true)
    user = User.find_by(login: login)
    if user.blank?
      # If we're logged in as an admin when we try to use a step that invokes
      # this method to create a user, user creation will fail because only some
      # admins can edit certain fields on pseuds. Setting current_user to nil
      # will bypass that.
      User.current_user = nil
      params = { login: login, password: password }
      params[:confirmed_at] = nil unless activate
      user = FactoryBot.create(:user, params)
      # Explicitly add pseud to autocomplete in test env as FactoryBot is not
      # triggering Sweeper hooks
      user.pseuds.first.add_to_autocomplete
    else
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

    # If we're logged in as an admin when we try to use a step that invokes this
    # method to create a user, user creation will fail because only some admins
    # can edit certain fields on pseuds. Setting current_user to nil will bypass
    # that.
    User.current_user = nil
    FactoryBot.create(:user, login: login).tap do |u|
      u.default_pseud.add_to_autocomplete
    end
  end
end

World(UserHelpers)
