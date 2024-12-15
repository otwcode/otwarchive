class FeedbacksController < ApplicationController
  skip_before_action :store_location
  before_action :load_support_languages

  def new
    @admin_setting = AdminSetting.current
    @feedback = Feedback.new
    @feedback.referer = request.referer
    if logged_in_as_admin?
      @feedback.email = current_admin.email
    elsif is_registered_user?
      @feedback.email = current_user.email
      @feedback.username = current_user.login
    end
  end

  def create
    @admin_setting = AdminSetting.current
    @feedback = Feedback.new(feedback_params)
    @feedback.rollout = @feedback.rollout_string
    @feedback.user_agent = request.env["HTTP_USER_AGENT"]
    @feedback.ip_address = request.remote_ip
    @feedback.referer = nil unless @feedback.referer && ArchiveConfig.PERMITTED_HOSTS.include?(URI(@feedback.referer).host)
    @feedback.site_skin = helpers.current_skin
    if @feedback.save
      @feedback.email_and_send
      flash[:notice] = t("successfully_sent",
        default: "Your message was sent to the Archive team - thank you!")
      redirect_back_or_default(root_path)
    else
      flash[:error] = t("failure_send",
        default: "Sorry, your message could not be saved - please try again!")
      render action: "new"
    end
  end

  private

  def load_support_languages
    @support_languages = Language.where(support_available: true).default_order
  end

  def feedback_params
    params.require(:feedback).permit(
      :comment, :email, :summary, :username, :language, :referer
    )
  end
end
