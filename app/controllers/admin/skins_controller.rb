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
    flash[:notice] = []
    modified_skin_titles = []
    %w(official rejected cached featured in_chooser).each do |action|
      skins_to_set = params["make_#{action}"] ? Skin.where(:id => params["make_#{action}"].map {|id| id.to_i}) : []
      skins_to_unset = params["make_un#{action}"] ? Skin.where(:id => params["make_un#{action}"].map {|id| id.to_i}) : []
      skins_to_set.each do |skin|
        case action
        when "official"
          skin.update_attribute(:official, true)
        when "rejected"
          skin.update_attribute(:rejected, true)
        when "cached"
          next unless skin.official? && !skin.is_a?(WorkSkin)
          skin.cache!
        when "featured"
          next unless skin.official? && !skin.is_a?(WorkSkin)
          skin.cache! unless skin.cached?
          skin.update_attribute(:featured, true)
        when "in_chooser"
          next unless skin.official? && !skin.is_a?(WorkSkin)
          skin.cache! unless skin.cached?
          skin.update_attribute(:in_chooser, true)
        end
        skin.update_attribute(:admin_note, params[:skin_admin_note]["#{skin.id}"]) if params[:skin_admin_note] && params[:skin_admin_note]["#{skin.id}"]        
        modified_skin_titles << skin.title
      end

      skins_to_unset.each do |skin|
        case action
        when "official"
          skin.clear_cache! # no cache for unofficial skins
          skin.update_attribute(:official, false)
          skin.remove_me_from_preferences
        when "rejected"
          skin.update_attribute(:rejected, false)
        when "cached"
          next unless skin.official? && !skin.is_a?(WorkSkin)
          skin.clear_cache! if skin.cached?
        when "featured"
          next unless skin.official? && !skin.is_a?(WorkSkin)
          skin.update_attribute(:featured, false)
        when "in_chooser"
          next unless skin.official? && !skin.is_a?(WorkSkin)
          skin.update_attribute(:in_chooser, false)
        end
        modified_skin_titles << skin.title
      end
    end

    flash[:notice] << ts("The following skins were updated: %{titles}", :titles => modified_skin_titles.join(', '))
    
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
