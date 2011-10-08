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
    
  def set_site_skin
    @site_skin = current_user.try(:preference).try(:skin) if current_user.is_a?(User) 
    @site_skin ||= AdminSetting.default_skin
  end
    
end

#BACK END, pls regularise this with the other blurbs so we just have <div class="icon"></div> and no image if no image uploaded?
