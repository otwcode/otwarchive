module CacheHelper

  def work_blurb_cache_key(work)
    key = 'work_' + work.id.to_s + '_' + work.updated_at.to_s
    key += hide_warnings?(work) ? '_hw' : '_sw'
  end
  
  def work_meta_cache_key(work)
    key = 'work_show_tags_' + work.id.to_s + '_' + work.updated_at.to_s
    key += hide_warnings?(work) ? '_hw' : '_sw'
  end
end