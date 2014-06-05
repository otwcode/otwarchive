class Admin::ActivitiesController < ApplicationController

  before_filter :admin_only

  def index
    @activities = AdminActivity.order("created_at DESC").page(params[:page])
  end

  def show
    @activity = AdminActivity.find(params[:id])
  end

end