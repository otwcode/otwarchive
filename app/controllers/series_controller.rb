class SeriesController < ApplicationController 
  before_filter :is_author, :only => [ :edit, :update, :destroy ]
  before_filter :check_user_status, :only => [:new, :create, :edit, :update]
  before_filter :check_permission_to_view, :only => [:show]
  
  # Only authors of the series should be able to edit it
  def is_author
    @series = Series.find(params[:id])
    unless current_user.is_a?(User) && current_user.is_author_of?(@series)
      flash[:error] = t('errors.no_permission_to_edit', :default => "Sorry, but you don't have permission to make edits.")
      redirect_to(@series)     
    end
  end
  
  # Hidden series should only be visible to admins and authors
  def check_permission_to_view
    @series = Series.find(params[:id])
    can_view_hidden = is_admin? || (current_user.is_a?(User) && current_user.is_author_of?(@series))
	  access_denied if (@series.hidden_by_admin? && !can_view_hidden)
  end
  
  # GET /series
  # GET /series.xml
  def index
    if params[:user_id]
      @user = User.find_by_login(params[:user_id])
      if params[:pseud_id]
        @author = @user.pseuds.find_by_name(params[:pseud_id])
        @series = @author.series.find(:all, :order => 'series.created_at DESC').paginate(:page => params[:page])
      else
        @series = @user.series.find(:all, :order => 'series.created_at DESC').paginate(:page => params[:page])
      end
    else
      @series = Series.find(:all, :order => 'series.created_at DESC').paginate(:page => params[:page])
    end
  end

  # GET /series/1
  # GET /series/1.xml
  def show
    @series = Series.find(params[:id])
    @serial_works = @series.serial_works.find(:all, :include => :work, :conditions => ['works.posted = ?', true], :order => :position) 
  end

  # GET /series/new
  # GET /series/new.xml
  def new
    @series = Series.new
  end

  # GET /series/1/edit
  def edit
    @series = Series.find(params[:id])
    @pseuds = current_user.pseuds
    @coauthors = @series.pseuds.select{ |p| p.user.id != current_user.id}
    to_select = @series.pseuds.blank? ? [current_user.default_pseud] : @series.pseuds
    @selected_pseuds = to_select.collect {|pseud| pseud.id.to_i }
  end
  
  # GET /series/1/manage
  def manage
    @series = Series.find(params[:id])
    @serial_works = @series.serial_works.find(:all, :include => [:work], :order => :position, :conditions => ['works.posted = ?', true])    
  end

  # POST /series
  # POST /series.xml
  def create
    @series = Series.new(params[:series])
    if @series.save
      flash[:notice] = t('notices.series.successfully_created', :default => 'Series was successfully created.')
      redirect_to(@series)
    else
      render :action => "new"
    end
  end

  # PUT /series/1
  # PUT /series/1.xml
  def update
    @series = Series.find(params[:id])
    
    unless params[:series][:author_attributes][:ids]
      flash[:error] = t('errors.series.author_removal_failed', :default => "Sorry, you cannot remove yourself entirely as an author of a series right now.")
      redirect_to edit_series_path(@series) and return
    end
    
    if params[:pseud] && params[:pseud][:byline] && params[:pseud][:byline] != "" && params[:series][:author_attributes]
      valid_pseuds = Pseud.parse_bylines(params[:pseud][:byline])[:pseuds] # an array
      valid_pseuds.each do |valid_pseud|
        params[:series][:author_attributes][:ids] << valid_pseud.id rescue nil
      end
      params[:pseud][:byline] = ""
    end

    if @series.update_attributes(params[:series])
      flash[:notice] = t('notices.series.successfully_updated', :default => 'Series was successfully updated.')
      redirect_to(@series)
    else
      render :action => "edit"
    end
  end
  
  def update_positions
    if params[:serial_works]
      @series = Series.find(params[:id])
      @series.reorder_works(params[:serial_works]) 
      flash[:notice] = t('notices.series.order_updated', :default => 'Series order has been successfully updated.')
      redirect_to(@series)
    else
      params[:sortable_series_list].each_with_index do |id, position|
        SerialWork.update(id, :position => position + 1)
        (@serial_works ||= []) << SerialWork.find(id)
      end
    end
  end

  # DELETE /series/1
  # DELETE /series/1.xml
  def destroy
    @series = Series.find(params[:id])
    if @series.destroy
      flash[:notice] = t('notices.series.successfully_deleted', :default => 'Series was successfully deleted.')
      redirect_to(current_user)
    else
      flash[:error] = t('errors.series.delete_failed', :default => "Sorry, we couldn't delete the series. Please try again.")
      redirect_to(@series)
    end
  end
end
