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
    @saved_work = current_user.saved_works.build(params[:saved_work])
    @saved_work.save!
    respond_to do |format|
      format.html { redirect_to @saved_work.work }
      format.json { render json: { saved_work_id: @saved_work.id }, status: :created }
    end
  end
  
  def destroy
    @saved_work = SavedWork.find(params[:id])
    @saved_work.destroy
    respond_to do |format|
      format.html { redirect_to @saved_work.work }
      format.json { render json: {}, status: :ok }
    end
  end
  
  private
  
  def load_user
    @user = User.find_by_login(params[:user_id])
    @check_ownership_of = @user
  end
  
end