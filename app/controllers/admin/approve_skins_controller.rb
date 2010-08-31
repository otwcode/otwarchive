class Admin::ApproveSkinsController < ApplicationController

  before_filter :admin_only

  def index
    @unapproved_skins = Skin.unapproved_skins
    @approved_skins = Skin.approved_skins
  end

  def update
    
    if !params[:make_unofficial].blank?
      params[:make_unofficial].each do |id|
        skin = Skin.find_by_id(id.to_i)
        skin.update_attribute(:official, false)
        skin.remove_me_from_preferences
      end
      flash[:notice] = 'Skins were unapproved and removed from preferences.'
    elsif !params[:make_official].blank?
      has_previews = false
      if params[:skin_icon].respond_to?(:values)
        previews = params[:skin_icon].values.reject{|v| v.blank?}
        has_previews = !previews.empty?
      end 
      if has_previews
        params[:make_official].each_with_index do |id, i|
          skin = Skin.find_by_id(id.to_i)
          skin.update_attribute(:official, true)
          skin.update_attribute(:icon, params[:skin_icon][id])
        end
        flash[:notice] = 'Skins were approved and preview images uploaded.'
      else
        params[:make_official].each do |id|
          skin = Skin.find_by_id(id.to_i)
          skin.update_attribute(:official, true)
        end
        flash[:notice] = 'Skins were approved.'
        flash[:error] = "Please note, this skin has no preview image. To fix this, unapprove it and then reapprove with a preview"
      end
    else
      flash[:error] = "Please select something"
    end
    redirect_to admin_approve_skins_path
  end

end
