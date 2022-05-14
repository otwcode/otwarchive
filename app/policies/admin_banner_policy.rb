class AdminBannerPolicy < ApplicationPolicy
  def manage?
    user_has_roles?(%w[superadmin board communications support])
  end

  alias index? manage?
  alias show? manage?
  alias create? manage?
  alias update? manage?
  alias destroy? manage?
end
