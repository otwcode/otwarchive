# Adds a cached "recent" lookup method to any class that mixes this in 
# will be mostly useful for small lookups eg for dashboard or running
# lists on front page
module CacheFinds
  module ClassMethods; end
  
  def self.included(klass)
    klass.extend(ClassMethods)
  end

  module ClassMethods
    def last(howmany)
      if ENV['RAILS_ENV'] != 'development'
        Rails.cache.fetch("#{self.name.to_s}.last_#{howmany.to_s}") {uncached_last(howmany)}
      else
        uncached_last(howmany)
      end
    end

    def recent
      last(ArchiveConfig.MAX_RECENT)
    end    

    protected

      def uncached_last(howmany)
        find(:all, :limit => howmany, :order => 'id DESC')
      end  
  end

end