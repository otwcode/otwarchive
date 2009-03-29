class AbuseReportsController < ApplicationController

  before_filter :admin_only, :except => [:new, :create]
  
  def access_denied
    flash[:error] = t('admin_only', :default => "I'm sorry, only an admin can look at that area.")
   redirect_to '/'
    false
  end

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
  end

  # POST /abuse_reports
  # POST /abuse_reports.xml
  def create
    @abuse_report = AbuseReport.new(params[:abuse_report])

    if @abuse_report.save
      AdminMailer.deliver_abuse_report(@abuse_report.email, @abuse_report.url, @abuse_report.comment)
      flash[:notice] = t('abuse_report_sent', :default => 'The Abuse Report was sent to the abuse team email alias.')
     redirect_to ''
    else
      render :action => 'new'
    end
  end

  def index
    @abuse_reports = AbuseReport.paginate(:page => params[:page])
  end
  
  def show
    @abuse_report = AbuseReport.find(params[:id])
  end

end
