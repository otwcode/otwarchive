class FeedSweeper < ActionController::Caching::Sweeper

  observe Work

  def after_create(work)
    if work.posted?
      expire_tag_feeds(work)
    end
  end

  def before_update(work)
    if work.posted? && work.posted_changed?
      expire_tag_feeds(work)
    end
  end

  private

  def expire_tag_feeds(work)
    tags = (work.tags + work.filters).uniq
    for tag in tags
      expire_page :controller => 'tags',
                  :action => 'feed',
                  :id => tag.id,
                  :format => 'atom'
    end
  end

end

