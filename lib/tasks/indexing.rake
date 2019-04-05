namespace :reindex do
  desc "Reindex bookmarks"
  task :bookmarks => :environment  do
    time = ENV['TIME_PERIOD'] || 'NOW() - INTERVAL 1 DAY'
    recent_works = Work.where("revised_at > #{time}")
    work_join = "JOIN works ON (bookmarks.bookmarkable_id = works.id AND " \
      "bookmarks.bookmarkable_type = 'Work')"
    Bookmark.joins(work_join).merge(recent_works).find_each do |b|
      IndexQueue.enqueue(b, :background)
    end
  end

  desc "Reindex works"
  task :works => :environment  do
    time = ENV['TIME_PERIOD'] || 'NOW() - INTERVAL 1 DAY'
    recent_works = Work.where("revised_at > #{time}")
    recent_works.find_each do |w|
      IndexQueue.enqueue(w, :background)
      IndexQueue.enqueue_ids(Bookmark, w.bookmark_ids, :background)
    end
  end

  desc "Clear cache works"
  task :works_cache => :environment  do
    time = ENV['TIME_PERIOD'] || 'NOW() - INTERVAL 1 DAY'
    recent_works = Work.where("revised_at > #{time}")
    recent_works.find_each(&:expire_caches)
  end
end
