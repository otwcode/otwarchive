# note, if you modify this file you have to restart the server or console
module SkinCacheHelper
  def skin_cache_key(skin)
    'skins_generation/' + (skin.type.nil? ? ("site_skin") : skin.id.to_s)
  end

  def skin_cache(skin)
    Rails.cache.increment(skin_cache_key(skin))
  end
end
