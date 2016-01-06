# note, if you modify this file you have to restart the server or console
module CacheHelper

  def skin_cache(skin)
    Rails.cache.increment('skins_generation/'+(skin.type.nil? ? ("site_skin") : skin.id.to_s) )
  end

end
