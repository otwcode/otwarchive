class ScheduledReindexJob

  def self.perform(reindex_type)
    classes = case reindex_type
              when 'main'
                %w(Pseud Tag Work Bookmark)
              when 'background'
                %w(Work Bookmark)
              when 'stats'
                %w(StatCounter)
              end
    classes.each{ |klass| run_queue(klass, reindex_type) }
  end

  def self.run_queue(klass, reindex_type)
    IndexQueue.new("index:#{klass.underscore}:#{reindex_type}").run
  end

end

