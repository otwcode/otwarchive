module Searchable

  def self.included(searchable)
    searchable.class_eval do
      after_save :enqueue_to_index
      after_destroy :enqueue_to_index
    end
    searchable.extend(ClassMethods)
  end

  module ClassMethods
    def successful_reindex(ids)
      # override to do something in response
    end
  end

  def enqueue_to_index
    if Rails.env.test?
      reindex_document and return
    end
    IndexQueue.enqueue(self, :main)
  end

  def indexers
    Indexer.for_object(self)
  end

  def reindex_document(options = {})
    # ES UPGRADE TRANSITION #
    # Remove `update_index rescue nil`
    update_index rescue nil

    # ES UPGRADE TRANSITION #
    # Remove outer conditional
    if self.class.use_new_search?
      responses = []
      self.indexers.each do |indexer|
        if options[:async]
          queue = options[:queue] || :main
          responses << AsyncIndexer.index(indexer, [id], queue)
        else
          responses << indexer.new([id]).index_document(self)
        end
      end
      responses
    end
  end
end
