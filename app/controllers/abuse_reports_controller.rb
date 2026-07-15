class AbuseReportsController < ApplicationController
  before_action :load_abuse_languages

  def new
    @abuse_report = AbuseReport.new
    reporter = current_admin || current_user
    if reporter.present?
      @abuse_report.email = reporter.email
      @abuse_report.username = reporter.login
    end
    @abuse_report.url = params[:url] || request.referer
  end

  def create
    @abuse_report = AbuseReport.new(abuse_report_params)
    @abuse_report.ip_address = request.remote_ip
    @abuse_report.user_agent = request.env["HTTP_USER_AGENT"].presence&.to(499)
    if @abuse_report.save
      if @abuse_report.email_and_send
        flash[:notice] = t(".success")
        redirect_to root_path
        return
      else
        flash[:error] = t(".failure_send")
        @abuse_report.destroy # avoid contributing to reporting limits
      end
    end
    render action: "new"
  end

  private

  def load_abuse_languages
    @abuse_languages = Language.where(abuse_support_available: true).default_order
  end

  def abuse_report_params
    params.require(:abuse_report).permit(
      :username, :email, :language, :summary, :url, :comment
    )
  end
end
