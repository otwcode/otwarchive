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
    # ES UPGRADE TRANSITION #
    # Remove `update_index rescue nil`
    update_index rescue nil

    # ES UPGRADE TRANSITION #
    # Remove outer conditional
    if self.class.use_new_search?
      index_name = self.is_a?(Tag) ? 'tag' : self.class.to_s.downcase
      doc_type = self.is_a?(Tag) ? 'tag' : self.class.document_type

      index = {
        index: "ao3_#{Rails.env}_#{index_name}s",
        type: doc_type,
        id: self.id,
        body: self.document_json
      }

      if self.is_a?(Bookmark)
        index.merge!(
          routing: "#{self.bookmarkable_type}-#{self.bookmarkable_id}"
        )
      end

      # ES UPGRADE TRANSITION #
      # Replace $new_elasticsearch with $elasticsearch
      $new_elasticsearch.index index
    end
  end
end
