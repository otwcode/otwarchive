class Admin::ApproveSkinsController < ApplicationController
  
  before_filter :admin_only

  def index
    @skins = Skin.public_skins
    @unapproved_skins = Skin.unapproved_skins
    @approved_skins = Skin.approved_skins
  end 
  
  def update
    if params[:official] == nil
      official = false
      else
      official = true
    end
    if Skin.update(params[:skin_id], :official => official)
      flash[:notice] = 'Skin settings were successfully updated.'
      redirect_to admin_approve_skins_path
    else
      render :action => "index"
    end
  end

end 
