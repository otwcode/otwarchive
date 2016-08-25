class Admin::BlacklistedEmailsController < ApplicationController

  before_filter :admin_only

  def index
    @admin_blacklisted_email = AdminBlacklistedEmail.new 
    if params[:query]
      @admin_blacklisted_emails = AdminBlacklistedEmail.where(["email LIKE ?", '%' + params[:query] + '%'])
      @admin_blacklisted_emails = @admin_blacklisted_emails.paginate(page: params[:page], per_page: ArchiveConfig.ITEMS_PER_PAGE)
    end
  end

  def new
    @admin_blacklisted_email = AdminBlacklistedEmail.new
  end

  def create
    @admin_blacklisted_email = AdminBlacklistedEmail.new(params[:admin_blacklisted_email])

    if @admin_blacklisted_email.save
      flash[:notice] = ts("Email address #{@admin_blacklisted_email.email} added to blacklist.")
      redirect_to admin_blacklisted_emails_url
    else
      render action: "index"
    end
  end

  def destroy
    @admin_blacklisted_email = AdminBlacklistedEmail.find(params[:id])
    @admin_blacklisted_email.destroy
    
    flash[:notice] = ts("Email address #{@admin_blacklisted_email.email} removed from blacklist.")
    redirect_to admin_blacklisted_emails_url
  end
end
