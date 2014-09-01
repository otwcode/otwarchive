module Searchable

  def self.included(searchable)
    searchable.class_eval do
      after_save :enqueue_to_index
      after_destroy :enqueue_to_index
    end
  end

  def self.successful_reindex(ids)
    # override to do something in response
  end

  def enqueue_to_index
    if Rails.env.test?
      update_index and return
    end
    REDIS_GENERAL.sadd("search_index_#{self.class.to_s.underscore}", self.id)
  end

end
