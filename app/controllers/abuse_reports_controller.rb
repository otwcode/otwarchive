class AbuseReportsController < ApplicationController

  skip_before_filter :store_location

  def new
    @abuse_report = AbuseReport.new
    @abuse_report.url = params[:url] || request.env["HTTP_REFERER"]
    @abuse_report.email = User.current_user.try(:email)
  end

  def create
    @abuse_report = AbuseReport.new(params[:abuse_report])
    if @abuse_report.save
      @abuse_report.email_and_send
      flash[:notice] = ts("Your abuse report was sent to the Abuse team.")
      redirect_to ""
    else
      render action: "new"
    end
  end

end
