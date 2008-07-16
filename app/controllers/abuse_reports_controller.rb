class AbuseReportsController < ApplicationController

  # GET /abuse_reports/new
  # GET /abuse_reports/new.xml
  def new
    @abuse_report = AbuseReport.new
    @abuse_report.url = request.env["HTTP_REFERER"]
    unless User.current_user == :false
      @abuse_report.email = User.current_user.email
    else
      @abuse_report.email = ""
    end

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # POST /abuse_reports
  # POST /abuse_reports.xml
  def create
    @abuse_report = AbuseReport.new(params[:abuse_report])

    respond_to do |format|
      if @abuse_report.save
        AdminMailer.deliver_abuse_report(@abuse_report.email, @abuse_report.url, @abuse_report.comment)

        flash[:notice] = 'The Abuse Report was sent to the abuse team email alias.'
        format.html { redirect_to '' }
      else
        format.html { render :action => "new" }
      end
    end
  end

end
