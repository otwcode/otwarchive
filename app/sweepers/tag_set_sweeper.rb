class TagSetSweeper < ActionController::Caching::Sweeper
  observe TagSet
  
  def after_create(tag_set)
    expire_cache_for(tag_set)
  end

  def after_update(tag_set)
    expire_cache_for(tag_set)
  end

  def after_destroy(tag_set)
    expire_cache_for(tag_set)
  end
  
  private
  def expire_cache_for(tag_set)
    # expire the tag_set show page and fragments
    expire_fragment("tag_set_show_#{tag_set.id}")
    TagSet::TAG_TYPES.each {|type| expire_fragment("tag_set_show_#{tag_set.id}_#{type}")}
    
  end

end