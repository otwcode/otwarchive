class ReindexJob
  def self.perform(klass, key)
    klass = klass.constantize
    case klass
    when StatCounter
      StatsIndexer.new(klass).run_subset(key)
    else
      AsyncIndexer.new(klass).run_subset(key)
    end
  end
end
