class ReindexJob

  def self.klass 
    raise "Not defined: use a subclass!"
  end

  def self.perform(key)
    AsyncIndexer.new(klass).run_subset(key)
  end

end

class WorkReindexJob < ReindexJob
  def self.klass; Work; end
end

class BookmarkReindexJob < ReindexJob
  def self.klass; Bookmark; end
end

class TagReindexJob < ReindexJob
  def self.klass; Tag; end
end

class PseudReindexJob < ReindexJob
  def self.klass; Pseud; end
end