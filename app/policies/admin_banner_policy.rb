class AdminBannerPolicy < ApplicationPolicy
  def index?
    user_has_roles?(%w[superadmin board board_assistants_team communications support])
  end

  alias show? index?
  alias create? index?
  alias update? index?
  alias destroy? index?
end
