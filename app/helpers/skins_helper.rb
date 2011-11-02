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
      link_to image_tag(skin.icon.url(:standard), :alt => skin.icon_alt_text, :class => "icon"), skin.icon.url(:original)
    end
  end
    
  # we use ||= here so the skin can be set already for previewing purposes
  def set_site_skin
    if params[:site_skin]
      @site_skin = Skin.approved_or_owned_by.usable.where(:id => params[:site_skin]).first
    end
    if session[:site_skin]
      @site_skin ||= Skin.approved_or_owned_by.usable.where(:id => session[:site_skin]).first
    end
    if logged_in? && current_user.preference
      @site_skin ||= current_user.preference.skin
    end
    @site_skin ||= AdminSetting.default_skin
  end

  def show_advanced_skin?(skin)
    !skin.new_record? && 
      (skin.role != Skin::DEFAULT_ROLE ||
        skin.media != Skin::DEFAULT_MEDIA ||
        skin.ie_condition.present? ||
        skin.unusable? ||
        !skin.skin_parents.empty?)
  end

end
