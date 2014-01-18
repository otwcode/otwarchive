class FeedSweeper < ActionController::Caching::Sweeper

  observe Chapter, Work

  def after_create(record)
    if record.posted? && (record.is_a?(Work) || (record.is_a?(Chapter) && record.work.present? && record.work.posted?))
      expire_caches(record)
    end
  end

  def after_update(record)
    if record.posted? && (record.posted_changed? || (record.is_a?(Work) && record.revised_at_changed?))
      expire_caches(record)
    end
  end
  
  def before_destroy(record)
    if record.posted?
      expire_caches(record)
    end
  end

  private

  def expire_caches(record)
    work = record
    work = record.work if record.is_a?(Chapter)
    
    return unless work.present?
    
    work.pseuds.each do |pseud|
      pseud.update_works_index_timestamp!
      pseud.user.update_works_index_timestamp!
    end
    
    work.approved_collections.each do |collection|
      collection.update_works_index_timestamp!
    end

    work.filters.each do |tag|
      # expire the index cache
      tag.update_works_index_timestamp!
      # expire the atom feed page for the tags on the work and the corresponding filter tags
      expire_page :controller => 'tags',
                  :action => 'feed',
                  :id => tag.id,
                  :format => 'atom'
    end
  end

end

