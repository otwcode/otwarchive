class SeriesController < ApplicationController
  before_action :check_user_status, only: [:new, :create, :edit, :update]
  before_action :load_series, only: [ :show, :edit, :update, :manage, :destroy, :confirm_delete ]
  before_action :check_ownership, only: [ :edit, :update, :manage, :destroy, :confirm_delete ]
  before_action :check_visibility, only: [:show]

  def load_series
    @series = Series.find_by(id: params[:id])
    unless @series
      raise ActiveRecord::RecordNotFound, "Couldn't find series '#{params[:id]}'"
    end
    @check_ownership_of = @series
    @check_visibility_of = @series
  end

  # GET /series
  # GET /series.xml
  def index
    unless params[:user_id]
      flash[:error] = ts("Whose series did you want to see?")
      redirect_to(root_path) and return
    end
    @user = User.find_by!(login: params[:user_id])
    @page_subtitle = t(".page_title", username: @user.login)

    @series = if current_user.nil?
                Series.visible_to_all
              else
                Series.visible_to_registered_user
              end

    if params[:pseud_id]
      @pseud = @user.pseuds.find_by!(name: params[:pseud_id])
      @page_subtitle = t(".page_title", username: @pseud.name)
      @series = @series.exclude_anonymous.for_pseud(@pseud)
    else
      @series = @series.exclude_anonymous.for_user(@user)
    end
    @series = @series.paginate(page: params[:page])
  end

  # GET /series/1
  # GET /series/1.xml
  def show
    @works = @series.works_in_order.posted.select(&:visible?).paginate(page: params[:page])

    # sets the page title with the data for the series
    if @series.unrevealed?
      @page_subtitle = t(".unrevealed_series")
    else
      @page_title = get_page_title(@series.allfandoms.collect(&:name).join(", "), @series.anonymous? ? t(".anonymous") : @series.allpseuds.collect(&:byline).join(", "), @series.title)
    end

    if current_user.respond_to?(:subscriptions)
      @subscription = current_user.subscriptions.where(subscribable_id: @series.id,
                                                       subscribable_type: 'Series').first ||
                      current_user.subscriptions.build(subscribable: @series)
    end
  end

  # GET /series/new
  # GET /series/new.xml
  def new
    @series = Series.new
  end

  # GET /series/1/edit
  def edit
    if params["remove"] == "me"
      pseuds_with_author_removed = @series.pseuds - current_user.pseuds
      if pseuds_with_author_removed.empty?
        redirect_to controller: 'orphans', action: 'new', series_id: @series.id
      else
        begin
          @series.remove_author(current_user)
          flash[:notice] = ts("You have been removed as a creator from the series and its works.")
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
    @serial_works = @series.serial_works.includes(:work).order(:position)
  end

  # POST /series
  # POST /series.xml
  def create
    @series = Series.new(series_params)
    if @series.save
      flash[:notice] = ts('Series was successfully created.')
      redirect_to(@series)
    else
      render action: "new"
    end
  end

  # PUT /series/1
  # PUT /series/1.xml
  def update
    @series.attributes = series_params
    if @series.errors.empty? && @series.save
      flash[:notice] = ts('Series was successfully updated.')
      redirect_to(@series)
    else
      render action: "edit"
    end
  end

  def update_positions
    if params[:serial_works]
      @series = Series.find(params[:id])
      @series.reorder_list(params[:serial_works])
      flash[:notice] = ts("Series order has been successfully updated.")
    elsif params[:serial]
      params[:serial].each_with_index do |id, position|
        SerialWork.update(id, position: position + 1)
        (@serial_works ||= []) << SerialWork.find(id)
      end
    end
    respond_to do |format|
      format.html { redirect_to series_path(@series) and return }
      format.json { head :ok }
    end
  end

  # GET /series/1/confirm_delete
  def confirm_delete
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

  private

  def series_params
    params.require(:series).permit(
      :title, :summary, :series_notes, :complete,
      author_attributes: [:byline, ids: [], coauthors: []]
    )
  end
end
