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
      unless @user
        raise ActiveRecord::RecordNotFound and return
      end
      @page_subtitle = ts("%{username} - Series", username: @user.login)
      pseuds = @user.pseuds
      if params[:pseud_id]
        @pseud = @user.pseuds.find_by_name(params[:pseud_id])
        unless @pseud
          raise ActiveRecord::RecordNotFound and return
        end
        @page_subtitle = ts("by ") + @pseud.byline
        pseuds = [@pseud]
      end
    end

    if current_user.nil?
      @series = Series.visible_to_all
    else
      @series = Series.visible_to_registered_user
    end
    if pseuds.present?
      @series = @series.exclude_anonymous.for_pseuds(pseuds)
    end
    @series = @series.paginate(:page => params[:page])
  end

  # GET /series/1
  # GET /series/1.xml
  def show
    @serial_works = @series.serial_works.find(:all, :include => :work, :conditions => ['works.posted = ?', true], :order => :position).select{|sw| sw.work.visible(User.current_user)}
    # sets the page title with the data for the series
    @page_title = @series.unrevealed? ? ts("Mystery Series") : get_page_title(@series.allfandoms.collect(&:name).join(', '), @series.anonymous? ? ts("Anonymous") : @series.allpseuds.collect(&:byline).join(', '), @series.title)
    if current_user.respond_to?(:subscriptions)
      @subscription = current_user.subscriptions.where(:subscribable_id => @series.id,
                                                       :subscribable_type => 'Series').first ||
                      current_user.subscriptions.build(:subscribable => @series)
    end
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
    
    if params["remove"] == "me"
      pseuds_with_author_removed = @series.pseuds - current_user.pseuds
      if pseuds_with_author_removed.empty?
        redirect_to :controller => 'orphans', :action => 'new', :series_id => @series.id
      else
        begin
          @series.remove_author(current_user)
          flash[:notice] = ts("You have been removed as an author from the series and its works.")
          redirect_to @series
        rescue Exception => error
          flash[:error] = error.message
          redirect_to @series        
        end
      end
    end    
  end
  
  # GET /series/1/manage
  def manage
    @serial_works = @series.serial_works.find(:all, :include => [:work], :order => :position)    
  end

  # POST /series
  # POST /series.xml
  def create
    @series = Series.new(params[:series])
    if @series.save
      flash[:notice] = ts('Series was successfully created.')
      redirect_to(@series)
    else
      render :action => "new"
    end
  end

  # PUT /series/1
  # PUT /series/1.xml
  def update
    unless params[:series][:author_attributes][:ids]
      flash[:error] = ts("Sorry, you cannot remove yourself entirely as an author of a series right now.")
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
      flash[:notice] = ts('Series was successfully updated.')
      redirect_to(@series)
    else
      @pseuds = current_user.pseuds
      @coauthors = @series.pseuds.select{ |p| p.user.id != current_user.id}
      to_select = @series.pseuds.blank? ? [current_user.default_pseud] : @series.pseuds
      @selected_pseuds = to_select.collect {|pseud| pseud.id.to_i }
      render :action => "edit"
    end
  end
  
  def update_positions
    if params[:serial_works]
      @series = Series.find(params[:id])
      @series.reorder(params[:serial_works])
      flash[:notice] = ts("Series order has been successfully updated.")
    elsif params[:serial]
      params[:serial].each_with_index do |id, position|
        SerialWork.update(id, :position => position + 1)
        (@serial_works ||= []) << SerialWork.find(id)
      end
    end
    respond_to do |format|
      format.html { redirect_to(@series) and return }
      format.js { render :nothing => true }
    end
  end

  # DELETE /series/1
  # DELETE /series/1.xml
  def destroy
    if @series.destroy
      flash[:notice] = ts("Series was successfully deleted.")
      redirect_to(current_user)
    else
      flash[:error] = ts("Sorry, we couldn't delete the series. Please try again.")
      redirect_to(@series)
    end
  end
end
