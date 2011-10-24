module SkinsHelper
  def skin_author_link(skin)
    if skin.author.is_a? User
      link_to(skin.byline, skin.author)
    else
      skin.byline
    end
  end
  
  def skin_preview_display(skin)
    if skin
      if skin.icon_file_name
        link_to image_tag(skin.icon.url(:standard), :alt => skin.icon_alt_text, :class => "icon"), skin.icon.url(:original)
      else
        image_tag(skin.icon.url(:standard), :alt => "", :class => "icon")
      end
    else
      image_tag("/images/skins/iconsets/default/icon_skins.png", :size => "100x100", :alt => "", :class => "icon")
    end
  end
    
  # we use ||= here so the skin can be set already for previewing purposes
  def set_site_skin
    if params[:site_skin]
      @site_skin = Skin.approved_or_owned_by.usable.where(:id => params[:site_skin]).first
    end
    if session[:site_skin]
      Rails.logger.info "&!&!&!&!&!&!  using skin #{session[:site_skin]}"
      @site_skin ||= Skin.approved_or_owned_by.usable.where(:id => session[:site_skin]).first
    end
    if logged_in? && current_user.preference
      @site_skin ||= Skin.includes(:parent_skins).find(current_user.preference.skin_id)
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

#BACK END, pls regularise this with the other blurbs so we just have <div class="icon"></div> and no image if no image uploaded?
