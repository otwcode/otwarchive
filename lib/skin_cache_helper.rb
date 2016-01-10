# note, if you modify this file you have to restart the server or console
module SkinCacheHelper
  def skin_cache_html_key(skin)
    'skins_style_tags/v1/' + \
    AdminSetting.default_skin.id.to_s + '/' + \
    Skin.default.id.to_s + '/' + \
    skin_cache_value(skin)
  end

  def skin_cache_footer_key
    'Skins_menu/v1/' + \
    (Rails.cache.fetch('skins_generation/site_skin')|| 0).to_s
  end

  def skin_cache_value(skin)
    (Rails.cache.fetch(skin_cache_key(skin)) || 0).to_s
  end

  def skin_cache_key(skin)
    'skins_generation/' + (skin.type.nil? ? ("site_skin") : skin.id.to_s)
  end

  def skin_cache(skin)
    Rails.cache.increment(skin_cache_key(skin))
  end
end
