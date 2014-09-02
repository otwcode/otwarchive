class ReindexJob
  def self.perform(klass, key)
    klass = klass.constantize
    case klass
    when StatCounter
      StatsIndexer.new(klass.constantize).run_subset(key)
    else
      AsyncIndexer.new(klass.constantize).run_subset(key)
    end
  end
end
