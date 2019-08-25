class Admin::ActivitiesController < Admin::BaseController

  def index
    @activities = AdminActivity.order("created_at DESC").page(params[:page])
  end

  def show
    @activity = AdminActivity.find(params[:id])
  end

end
