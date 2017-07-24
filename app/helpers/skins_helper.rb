module SkinsHelper
  def skin_author_link(skin)
    if skin.author.is_a? User
      link_to(skin.byline, skin.author)
    else
      skin.byline
    end
  end

  # we only actually display an image if there's a file
  def skin_preview_display(skin)
    if skin && skin.icon_file_name
      link_to image_tag(skin.icon.url(:standard), alt: skin.icon_alt_text, class: "icon", skip_pipeline: true), skin.icon.url(:original)
    end
  end

  # we use ||= here so the skin can be set already for previewing purposes
  def set_site_skin
    if params[:site_skin]
      @site_skin = Skin.approved_or_owned_by.usable.where(id: params[:site_skin]).first
    end
    if (logged_in? || logged_in_as_admin?) && session[:site_skin]
      @site_skin ||= Skin.approved_or_owned_by.usable.where(id: session[:site_skin]).first
    end
    if logged_in? && current_user.preference
      @site_skin ||= current_user.preference.skin
    end
    @site_skin ||= AdminSetting.default_skin
  end

  def get_skin_cache(skin)
    return "" unless skin
    roles = []
    if logged_in_as_admin?
      roles << "admin"
    end
    skin_cache_key = "site_skin_#{skin.id}_#{skin.updated_at}" 
    skin_cache_key += "_#{roles.join('_')}" unless roles.empty? 
    roles += Skin::DEFAULT_ROLES_TO_INCLUDE

    return [skin_cache_key, roles]
  end

  def show_advanced_skin?(skin)
    !skin.new_record? && 
      (skin.role != Skin::DEFAULT_ROLE ||
        (skin.media.present? && skin.media != Skin::DEFAULT_MEDIA) ||
        skin.ie_condition.present? ||
        skin.unusable? ||
        !skin.skin_parents.empty?)
  end

  def my_site_skins_link(link_text = nil)
    link_text ||= "My Site Skins"
    span_if_current ts(link_text), user_skins_path(current_user, skin_type: "Site"), current_page?(user_skins_path(current_user)) && (params[:skin_type].blank? || params[:skin_type] == "Site")
  end
  
  def my_work_skins_link(link_text = nil)
    link_text ||= "My Work Skins"
    span_if_current ts(link_text), user_skins_path(current_user, skin_type: "WorkSkin")
  end

  def public_site_skins_link(link_text = nil)
    link_text ||= "Public Site Skins"
    span_if_current ts(link_text), skins_path(skin_type: "Site"), current_page?(skins_path) && (params[:skin_type].blank? || params[:skin_type] == "Site")
  end
  
  def public_work_skins_link(link_text = nil)
    link_text ||= "Public Work Skins"
    span_if_current ts(link_text), skins_path(skin_type: "WorkSkin")
  end

end
