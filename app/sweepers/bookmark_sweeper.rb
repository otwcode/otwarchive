class BookmarkSweeper < ActionController::Caching::Sweeper
  observe Bookmark

  def after_save(record)
    expire_fragment("bookmark-owner-blurb-#{record.id}")
    expire_fragment("bookmark-blurb-#{record.id}")
  end
end
