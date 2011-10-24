class Admin::SkinsController < ApplicationController

  before_filter :admin_only

  def index
    @unapproved_skins = Skin.unapproved_skins.sort_by_recent
  end

  def index_rejected
    @rejected_skins = Skin.rejected_skins.sort_by_recent
  end

  def index_approved
    @approved_skins = Skin.approved_skins.usable.sort_by_recent
  end

  def update

    # make sure we have something to work with
    if params[:make_official].blank? && params[:make_unofficial].blank? && params[:make_rejected].blank? && params[:make_unrejected].blank? && params[:make_cached].blank?
      flash[:error] = "Please select at least one skin to modify!"
    else        
      flash[:notice] = []
    end
    
    # approve skins
    if !params[:make_official].blank?
      notice = 'The following skins were approved: '
      params[:make_official].each do |id|
        skin = Skin.find_by_id(id.to_i)
        skin.update_attribute(:official, true)
        skin.update_attribute(:admin_note, params[:skin_admin_note][id])
        notice += "#{skin.title} "
      end
      flash[:notice] << notice
    end
    
    # unapprove skins
    if !params[:make_unofficial].blank?
      notice = 'The following skins were unapproved and removed from preferences: '
      params[:make_unofficial].each do |id|
        skin = Skin.find_by_id(id.to_i)
        skin.clear_cache! # no cache for unofficial skins
        skin.update_attribute(:official, false)
        skin.remove_me_from_preferences
        notice += "#{skin.title} "
      end
      flash[:notice] << notice
    end
    
    # reject skins
    if !params[:make_rejected].blank?
      notice += 'The following skins were marked as rejected: '
      params[:make_rejected].each do |id|
        skin = Skin.find_by_id(id.to_i)
        skin.update_attribute(:rejected, true)
        skin.update_attribute(:admin_note, params[:skin_admin_note][id])
        notice += "#{skin.title} "
      end
      flash[:notice] << notice
    end

    # unreject skins
    if !params[:make_unrejected].blank?
      notice = 'The following skins were marked as unrejected: '
      params[:make_unrejected].each do |id|
        skin = Skin.find_by_id(id.to_i)
        skin.update_attribute(:rejected, false)
        notice += "#{skin.title} "
      end
      flash[:notice] << notice
    end    
    
    # make skins cached
    if !params[:make_cached].blank?
      now_cached_skins = []
      params[:make_cached].each do |id|
        skin = Skin.find_by_id(id.to_i)
        if skin.official? && !skin.is_a?(WorkSkin)
          skin.cache!
          now_cached_skins << skin.title
        else
          flash[:error] = "Note: only approved public site skins can be cached."
        end
      end      
      flash[:notice] << ts("The following skins were marked for caching: %{skins}", :skins => now_cached_skins.join(", "))
    end
    
    # make skins uncached
    if !params[:make_uncached].blank?
      now_uncached_skins = []
      params[:make_cached].each do |id|
        skin = Skin.find_by_id(id.to_i)
        if skin.cached?
          skin.clear_cache!
          now_uncached_skins << skin.title
        else
          flash[:error] = "Note: only cached skins can be uncached."
        end
      end
      flash[:notice] << ts('The following skins had their caches cleared: %{skins}', :skins => now_uncached_skins.join(", "))
    end
    
    # set default
    if params[:set_default].present? && params[:set_default] != AdminSetting.default_skin.title
      skin = Skin.find_by_title_and_official(params[:set_default], true)
      @admin_setting = AdminSetting.first
      if skin && @admin_setting
        @admin_setting.default_skin = skin
        @admin_setting.last_updated_by = params[:last_updated_by]
        unless @admin_setting.save
          flash[:error] = ts("We couldn't save the default skin change.")
        else
          flash[:notice] << ts("Default skin changed to %{title}", skin.title)
        end
      end
    end
    
    redirect_to admin_skins_path
  end

end
