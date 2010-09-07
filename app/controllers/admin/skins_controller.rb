class Admin::SkinsController < ApplicationController

  before_filter :admin_only

  def index
    @unapproved_skins = Skin.unapproved_skins
  end

  def index_rejected
    @rejected_skins = Skin.rejected_skins
  end

  def index_approved
    @approved_skins = Skin.approved_skins
  end

  def update

    # make sure we have something to work with
    if params[:make_official].blank? && params[:make_unofficial].blank? && params[:make_rejected].blank? && params[:make_unrejected].blank?
      flash[:error] = "Please select at least one skin to modify!"
    else        
      flash[:notice] = ""
    end
    
    # approve skins
    if !params[:make_official].blank?
      flash[:notice] += 'The following skins were approved: '
      params[:make_official].each do |id|
        skin = Skin.find_by_id(id.to_i)
        skin.update_attribute(:official, true)
        skin.update_attribute(:admin_note, params[:skin_admin_note][id])
        flash[:notice] += "#{skin.title} "
      end
    end
    
    # unapprove skins
    if !params[:make_unofficial].blank?
      flash[:notice] += 'The following skins were unapproved and removed from preferences: '
      params[:make_unofficial].each do |id|
        skin = Skin.find_by_id(id.to_i)
        skin.update_attribute(:official, false)
        skin.remove_me_from_preferences
        flash[:notice] += "#{skin.title} "
      end
      flash[:notice] += '<br />'
    end
    
    # reject skins
    if !params[:make_rejected].blank?
      flash[:notice] += 'The following skins were marked as rejected: '
      params[:make_rejected].each do |id|
        skin = Skin.find_by_id(id.to_i)
        skin.update_attribute(:rejected, true)
        skin.update_attribute(:admin_note, params[:skin_admin_note][id])
        flash[:notice] += "#{skin.title} "
      end
      flash[:notice] += '<br />'
    end

    # unreject skins
    if !params[:make_unrejected].blank?
      flash[:notice] += 'The following skins were marked as unrejected: '
      params[:make_unrejected].each do |id|
        skin = Skin.find_by_id(id.to_i)
        skin.update_attribute(:rejected, false)
        flash[:notice] += "#{skin.title} "
      end
      flash[:notice] += '<br />'
    end    
    
    redirect_to admin_skins_path
  end

end
