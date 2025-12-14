class Users::SessionsController < Devise::SessionsController
  layout "session"
  before_action :admin_logout_required

  # POST /users/login
  def create
    super do |resource|
      unless resource.remember_me
        message = t("users.sessions.no_remember_me_warning_html",
                    number: ArchiveConfig.DEFAULT_SESSION_LENGTH_IN_WEEKS)
      end
      flash[:notice] += message unless message.nil?
      flash[:notice] = flash[:notice].html_safe

      if resource.suspended? || resource.banned?
        if resource.suspended?
          suspension_end = effective_suspension_end_date(resource)
          flash[:error] = t("users.status.suspension_notice_html",
                            suspended_until: suspension_end,
                            contact_abuse_link: view_context.link_to(
                              t("users.contact_abuse"),
                              new_abuse_report_path
                            ))
        else
          flash[:error] = t("users.status.ban_notice_html",
                            contact_abuse_link: view_context.link_to(
                              t("users.contact_abuse"),
                              new_abuse_report_path
                            ))
        end
      end
    end
  end

  # GET /users/logout
  def confirm_logout
    # If the user is already logged out, we just redirect to the front page.
    redirect_to root_path unless user_signed_in?
  end

  include PathCleaner
  # DELETE /users/logout
  def destroy
    signed_out = (Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name))
    set_flash_message! :notice, :signed_out if signed_out

    redirect_to relative_path(params[:return_to]) || root_path
  end
end
