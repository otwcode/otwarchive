class ExternalWorksController < ApplicationController
  before_filter :admin_only, :only => [:edit, :update, :compare, :merge]  
  before_filter :users_only, :only => [:new]
  before_filter :check_user_status, :only => [:new]
  
  def new
    @bookmarkable = ExternalWork.new
    @bookmark = Bookmark.new
  end
  
  # Used with bookmark form to get an existing external work and return it via ajax
  def fetch
   if params[:external_work_url]
     url = ExternalWork.new.reformat_url(params[:external_work_url])
     @external_work = ExternalWork.where(:url => url).first
   end
   respond_to do |format|
    format.js
   end
  end
  
  def index
    if params[:show] == 'duplicates'
      @external_works = ExternalWork.duplicate.order("created_at DESC").paginate(:page => params[:page])      
    else
      @external_works = ExternalWork.order("created_at DESC").paginate(:page => params[:page])
    end
  end
  
  def show
    @external_work = ExternalWork.find(params[:id])
  end
  
  def edit
    @external_work = ExternalWork.find(params[:id])
    @work = @external_work
  end
  
  def update
    @external_work = ExternalWork.find(params[:id])
    @external_work.attributes = params[:work]
    if @external_work.update_attributes(params[:external_work])
      flash[:notice] = t('successfully_updated', :default => 'External work was successfully updated.')
      redirect_to(@external_work)
    else
      render :action => "edit"
    end
  end
  
end
