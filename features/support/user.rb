module UserHelpers
  def find_or_create_new_user(login, password, activate: true)
    user = User.find_by(login: login)
    if user.blank?
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
end

World(UserHelpers)
