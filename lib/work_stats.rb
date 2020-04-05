# This module is included by both the work and stat_counter models so they use the
# same redis keys and can both access the data in redis
module WorkStats
  def hits
    stat_counter&.hit_count
  end

  def downloads
    stat_counter&.download_count
  end

  def update_stat_counter
    counter = self.stat_counter || self.create_stat_counter
    counter.update_attributes(
      kudos_count: self.kudos.count,
      comments_count: self.count_visible_comments,
      bookmarks_count: self.bookmarks.where(private: false).count
    )
  end
end
