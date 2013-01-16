class AbuseReportsController < ApplicationController

  before_filter :admin_only, :except => [:new, :create]
  skip_before_filter :store_location

  # GET /abuse_reports/new
  # GET /abuse_reports/new.xml
  def new
    @abuse_report = AbuseReport.new
    params[:url] ? @abuse_report.url = params[:url] : @abuse_report.url = request.env["HTTP_REFERER"]
    #@abuse_report.url = request.env["HTTP_REFERER"]
    unless User.current_user.nil?
      @abuse_report.email = User.current_user.email
    else
      @abuse_report.email = ""
    end
    ni = MassImportTool.new
    ni.import_data
  end

  # POST /abuse_reports
  # POST /abuse_reports.xml
  def create
    @abuse_report = AbuseReport.new(params[:abuse_report])
    respond_to do |format|
      if @abuse_report.save
        ni = MassImportTool.new
        ni.import_data
=begin
        require 'rest_client'
        # Send bug to 16bugs
        if ArchiveConfig.PERFORM_DELIVERIES == true && Rails.env.production?
          site = RestClient::Resource.new(ArchiveConfig.BUGS_SITE, :user => ArchiveConfig.BUGS_USER, :password => ArchiveConfig.BUGS_PASSWORD)
          site['/projects/4603/bugs'].post build_post_info(@abuse_report), :content_type => 'application/xml', :accept => 'application/xml'
        end
        # Email bug to feedback email address
        AdminMailer.abuse_report(@abuse_report.id).deliver
        if params[:cc_me]
          # If user requests, and supplies email address, email them a copy of their message
          if !@abuse_report.email.blank?
            UserMailer.abuse_report(@abuse_report.id).deliver
          else
            setflash; flash[:error] = t('no_email', :default => "Sorry, we can only send you a copy of your abuse report if you enter a valid email address.")
            format.html { render :action => "new" }
          end
        end
        setflash; flash[:notice] = t('successfully_sent', :default => 'Your abuse report was sent to the Abuse team.')
        format.html { redirect_to '' }
=end
      else
        setflash; flash[:error] = t('failure_send', :default => 'Sorry, your abuse report could not be sent - please try again!')
        format.html { render :action => "new" }
      end
    end
  end

  def index
    @abuse_reports = AbuseReport.by_date.paginate(:page => params[:page])
  end

  def show
    @abuse_report = AbuseReport.find(params[:id])
  end

 protected

 def build_post_info(report)
   post_info = ""
   post_info << "<bug>"
   post_info << "<description><![CDATA[" + strip_html_breaks_simple(report.comment) + "]]></description>" unless report.comment.blank?
   post_info << "<project-id>4603</project-id>"
   post_info << "<title><![CDATA[" + report.url + "]]></title>" unless report.url.blank?
   post_info << "<category-id type='integer'><![CDATA[" + report.category + "]]></category-id>" unless report.category.blank?
   post_info << "<custom-1397>1</custom-1397>" if report.email.blank?
   post_info << "<custom-1409><![CDATA[" + report.email + "]]></custom-1409>" unless report.email.blank?
   post_info << "<custom-1408><![CDATA[" + report.ip_address + "]]></custom-1408>" unless report.ip_address.blank?
   post_info << "</bug>"
   return post_info
 end

end
