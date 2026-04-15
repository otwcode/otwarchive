module SkinCacheHelper
  def cache_timestamp
    Time.now.utc.to_fs(:usec)
  end

  def skin_cache_version_key(skin_id)
    skin_id = skin_id.id if skin_id.is_a?(Skin)
    [:v1, :site_skin, skin_id, :version_key]
  end

  def skin_cache_version(skin_id)
    Rails.cache.fetch(skin_cache_version_key(skin_id)) do
      cache_timestamp
    end
  end

  def skin_cache_version_update(skin_id)
    Rails.cache.write(skin_cache_version_key(skin_id), cache_timestamp)
  end

  def skin_chooser_key
    [:v3, :skin_chooser]
  end

  def skin_chooser_expire_cache
    Rails.cache.delete(skin_chooser_key)
  end

  def skin_chooser_data
    Rails.cache.fetch(skin_chooser_key) do
      Skin.in_chooser.order(:title).map do |skin|
        {
          title: skin.title,
          # Cache the parameters that we need for generating the skin URL later
          # We can't cache the record itself (for later URL generation) since it could change or be deleted
          param: skin.to_param
        }
      end
    end
  end
end
