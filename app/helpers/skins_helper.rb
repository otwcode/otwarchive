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
        image_tag(skin.icon.url(:standard), :alt => "No skin preview available", :class => "icon")
      end
    else
      image_tag("/images/skin_preview_none.png", :size => "100x100", :alt => "No skin preview available", :class => "icon")
    end
  end
    
end
