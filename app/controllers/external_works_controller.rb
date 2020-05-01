class ExternalWorksController < ApplicationController
  before_action :admin_only, only: [:edit, :update, :compare, :merge]
  before_action :users_only, only: [:new]
  before_action :check_user_status, only: [:new]

  def new
    @bookmarkable = ExternalWork.new
    @bookmark = Bookmark.new
  end

  # Used with bookmark form to get an existing external work and return it via ajax
  def fetch
   if params[:external_work_url]
     url = ExternalWork.new.reformat_url(params[:external_work_url])
     @external_work = ExternalWork.where(url: url).first
   end
   respond_to do |format|
    format.json { render 'fetch.js.erb' }
   end
  end

  def index
    if params[:show] == 'duplicates'
      @external_works = ExternalWork.duplicate.order("created_at DESC").paginate(page: params[:page])
    else
      @external_works = ExternalWork.order("created_at DESC").paginate(page: params[:page])
    end
  end

  def show
    @external_work = ExternalWork.find(params[:id])
  end

  def edit
    @external_work = ExternalWork.find(params[:id])
    @work = @external_work
    authorize current_admin, policy_class: AdminModerationPolicy
  end

  def update
    @external_work = ExternalWork.find(params[:id])
    @external_work.attributes = work_params
    if @external_work.update_attributes(external_work_params)
      flash[:notice] = t('successfully_updated', default: 'External work was successfully updated.')
      redirect_to(@external_work)
    else
      render action: "edit"
    end
  end

  private

  def external_work_params
    params.require(:external_work).permit(
      :url, :author, :title, :summary
    )
  end

  def work_params
    params.require(:work).permit(
        :rating_string, :fandom_string, :relationship_string, :character_string,
        :freeform_string, category_string: [], archive_warning_strings: []
    )
  end
end
