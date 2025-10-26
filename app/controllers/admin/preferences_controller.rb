class Admin::PreferencesController < Admin::BaseController
  before_action :require_admin_owner

  def show
    @totp_enabled = current_admin.otp_required_for_login
  end
end
