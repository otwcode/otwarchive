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
      update_index and return
    end
    IndexQueue.enqueue(self, :main)
  end

end
