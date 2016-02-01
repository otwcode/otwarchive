# note, if you modify this file you have to restart the server or console
module SkinCacheHelper
  def skin_cache_html_key(skin, roles_to_include)
    'skins_style_tags/v3' + \
      AdminSetting.default_skin.id.to_s + '/' + \
      Skin.default.id.to_s + '/' + \
      roles_to_include.to_s + '/' + \
      skin_cache_value(skin) + '/' + \
      skin.id.to_s
  end

  def skin_cache_footer_key
    'Skins_menu/v1/' + \
    (Rails.cache.fetch('skins_generation/site_skin') || 0).to_s
  end

  def skin_cache_value(skin)
    (Rails.cache.fetch(skin_memcache_cache_key(skin)) || 0).to_s
  end

  def skin_memcache_cache_key(skin)
    'skins_generation/' + (skin.type.nil? ? ("site_skin_#{skin.id.to_s}") : "work_skin_#{skin.id.to_s}")
  end

  def skin_cache(skin)
    Rails.cache.increment(skin_memcache_cache_key(skin))
    Rails.cache.increment('skins_generation/site_skin')  # This is the general key used for the footer
  end

  def skin_invalidate_cache
    skin_cache(self)
    if self.type.nil?
      child_list = SkinParent.where(:parent_skin_id => self.id)
      unless child_list.nil?
        child_list.each do |child_skin| 
          unless child_skin.child_skin_id == self.id
            Skin.find(child_skin.child_skin_id).skin_invalidate_cache
          end
        end
      end
    end
  end
end
