module ES
  class BookmarkedWorkIndexer < ES::BookmarkableIndexer
    def self.klass
      "Work"
    end

    def self.index_all(options={})
      works = Work.joins(:stat_counter).where("bookmarks_count > 0")
      total = (works.count / 1000) + 1
      i = 1
      works.find_in_batches do |group|
        puts "Reindexing #{klass} batch #{i} of #{total}"
        self.new(group.map(&:id)).index_documents
        i += 1
      end
    end
  end
end