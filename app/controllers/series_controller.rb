class SeriesController < ApplicationController 
  before_filter :check_user_status, :only => [:new, :create, :edit, :update]
  before_filter :load_series, :only => [ :show, :edit, :update, :manage, :destroy ] 
  before_filter :check_ownership, :only => [ :edit, :update, :manage, :destroy ] 
  before_filter :check_visibility, :only => [:show]
  
  def load_series
    @series = Series.find(params[:id])
    @check_ownership_of = @series
    @check_visibility_of = @series  
  end
  
  # GET /series
  # GET /series.xml
  def index
    if params[:user_id]
      @user = User.find_by_login(params[:user_id])
      if params[:pseud_id]
        @author = @user.pseuds.find_by_name(params[:pseud_id])
        @series = @author.series.select{|s| s.visible?(current_user)}
      else
        @series = @user.series.select{|s| s.visible?(current_user)}
      end
    else
      @series = Series.find(:all, :order => 'series.created_at DESC').select{|s| s.visible?(User.current_user)}
    end
    @series = @series.paginate(:page => params[:page])
  end

  # GET /series/1
  # GET /series/1.xml
  def show
    @serial_works = @series.serial_works.find(:all, :include => :work, :conditions => ['works.posted = ?', true], :order => :position).select{|sw| sw.work.visible(User.current_user)}
  end

  # GET /series/new
  # GET /series/new.xml
  def new
    @series = Series.new
  end

  # GET /series/1/edit
  def edit
    @pseuds = current_user.pseuds
    @coauthors = @series.pseuds.select{ |p| p.user.id != current_user.id}
    to_select = @series.pseuds.blank? ? [current_user.default_pseud] : @series.pseuds
    @selected_pseuds = to_select.collect {|pseud| pseud.id.to_i }
  end
  
  # GET /series/1/manage
  def manage
    @serial_works = @series.serial_works.find(:all, :include => [:work], :order => :position, :conditions => ['works.posted = ?', true])    
  end

  # POST /series
  # POST /series.xml
  def create
    @series = Series.new(params[:series])
    if @series.save
      flash[:notice] = t('successfully_created', :default => 'Series was successfully created.')
      redirect_to(@series)
    else
      render :action => "new"
    end
  end

  # PUT /series/1
  # PUT /series/1.xml
  def update
    unless params[:series][:author_attributes][:ids]
      flash[:error] = t('author_removal_failed', :default => "Sorry, you cannot remove yourself entirely as an author of a series right now.")
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
      flash[:notice] = t('successfully_updated', :default => 'Series was successfully updated.')
      redirect_to(@series)
    else
      render :action => "edit"
    end
  end
  
  def update_positions
    if params[:serial_works]
      @series = Series.find(params[:id])
      @series.reorder(params[:serial_works])
      flash[:notice] = t('order_updated', :default => 'Series order has been successfully updated.')
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
    if @series.destroy
      flash[:notice] = t('successfully_deleted', :default => 'Series was successfully deleted.')
      redirect_to(current_user)
    else
      flash[:error] = t('delete_failed', :default => "Sorry, we couldn't delete the series. Please try again.")
      redirect_to(@series)
    end
  end
end