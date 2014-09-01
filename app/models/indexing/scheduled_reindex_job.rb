class ScheduledReindexJob

  INDEXED_TYPES = %w(Pseud Tag Work Bookmark)

  def self.perform(reindex_type)
    case reindex_type
    when 'main'
      INDEXED_TYPES.each do |klass|
        AsyncIndexer.new(klass.constantize).perform
      end
    when 'background'
      %w(Work Bookmark).each do |klass|
        AsyncIndexer.new(klass.constantize, label: :background).perform
      end
    when 'stats'
      StatsIndexer.new(StatCounter).perform
    end
  end

end

