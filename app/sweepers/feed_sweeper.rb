class FeedSweeper < ActionController::Caching::Sweeper

  observe Chapter, Work

  def after_create(record)
    if record.posted? && (record.is_a?(Work) || record.is_a?(Chapter) && record.work.present? && record.work.posted?)
      expire_tag_caches(record)
    end
  end

  def after_update(record)
    if record.posted? && (record.posted_changed? || record.is_a?(Work) && record.revised_at_changed?)
      expire_tag_caches(record)
    end
  end

  private

  def expire_tag_caches(record)
    work = record
    work = record.work if record.is_a?(Chapter)

    tags = (work.tags + work.filters).uniq
    tags.each do |tag|
      # expire the index cache
      tag.update_work_index_timestamp!
      # expire the atom feed page for the tags on the work and the corresponding filter tags
      expire_page :controller => 'tags',
                  :action => 'feed',
                  :id => tag.id,
                  :format => 'atom'
    end
  end

end

