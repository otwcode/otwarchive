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

  def reindex_document
    update_index rescue nil
    if self.class.use_new_search?
      $new_elasticsearch.index(
        index: "ao3_#{Rails.env}_#{self.class.to_s.downcase}s",
        type: self.class.document_type,
        id: self.id,
        body: self.document_json
      )
    end
  end
end
