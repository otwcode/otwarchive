class Admin::ApiController < ApplicationController
  before_filter :admin_only
  before_filter :check_for_cancel, only: [:create, :update]

  def index
    @api_keys = ApiKey.all
  end

  def show
    redirect_to action: 'index'
  end

  def new
    @api_key = ApiKey.new
  end

  def create
    @api_key = ApiKey.new(params[:api_key])
    if @api_key.save
      flash[:notice] = ts('New token successfully created')
      redirect_to action: 'index'
    else
      render 'new'
    end
  end

  def edit
    @api_key = ApiKey.find(params[:id])
  end

  def update
    @api_key = params[:api_key]
    if ApiKey.update(params[:id], @api_key)
      flash[:notice] = ts('Access token name was successfully updated')
      redirect_to action: 'index'
    else
      render 'edit'
    end
  end

  def destroy
    @api_key = ApiKey.find(params[:id])
    @api_key.destroy
    redirect_to(admin_api_path)
  end

  private

  def check_for_cancel
    if params[:cancel_button]
      redirect_to action: 'index'
    end
  end
end
