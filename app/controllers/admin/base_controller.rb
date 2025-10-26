class Admin::BaseController < ApplicationController
  before_action :admin_only

  protected

  # This is the equivalent of the check_ownership method, but for admins.
  # It's mostly used for admin-specific account configuration, like TOTP setup.
  def require_admin_owner
    return if params[:admin_id] == current_admin.login

    respond_to do |format|
      format.html do
        flash[:error] = t("admin.access.permission_denied_generic")
        redirect_to root_path
      end
    end
  end
end
