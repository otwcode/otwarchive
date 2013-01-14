# Used to generate cache keys for any works index page
# Include in models that can "own" works, eg ...tags/TAGNAME/works or users/LOGIN/works
# See tag.rb for example of how to customize the behavior
module WorksOwner
  
  # Used in works_controller to determine whether to expire the cache for this object's works index page
  # This should change (and thereby automatically invalidates the cache) any time 
  # one of the owning object's works is created, updated, deleted, or orphaned. 
  # * The most-recent-updated-at date will capture any work being created or updated
  # * The count of works will capture an older work being deleted or orphaned
  # * Can't keep both the same if one of those things has changed!
  # * Note: to deal with wrangling changes making the filters stale, works are "touched" when they are 
  #   reindexed for those changes, in the RedisSearchIndexQueue, which will change the updated_at 
  #   dates on the works involved.   
  def works_index_cache_key(tag=nil, index_works=nil)
    cache_key = "works_index_for_#{self.class.name.underscore}_#{self.id}_"
    index_works ||= self.works.where(:posted => true)
    if tag.present?
      cache_key << "tag_#{tag.id}_"
      if tag.canonical?
        index_works = index_works.joins(:filter_taggings).where("filter_taggings.filter_id = ?", tag.id)
      else
        index_works = index_works.joins(:taggings).where("taggings.tagger_id = ?", tag.id)
      end
    end
    cache_key << index_works.count.to_s
    cache_key << "_"
    cache_key << index_works.order("updated_at DESC").limit(1).value_of(:updated_at).first.to_s
  end
    
  
end