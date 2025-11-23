class Admin::PreferencesController < Admin::BaseController
  before_action :require_admin_owner

  def show
    @totp_enabled = current_admin.otp_required_for_login
  end

  private

  def require_admin_owner
    return if params[:admin_id] == current_admin.login

    flash[:error] = t("admin.preferences.access.permission_denied_generic")
    redirect_to root_path
  end
end
