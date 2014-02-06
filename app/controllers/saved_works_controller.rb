class SavedWorksController < ApplicationController
  
  skip_before_filter :store_location, only: [ :create, :destroy ]
  before_filter :users_only
  before_filter :load_user
  before_filter :check_ownership
  
  respond_to :html, :json
  
  def index
    @works = SavedWork.works_for_user(current_user).page(params[:page])
  end
  
  def create
    respond_with current_user.saved_works.create(work_id: params[:work_id])
  end
  
  def destroy
    respond_with SavedWork.find(params[:id]).destroy
  end
  
end