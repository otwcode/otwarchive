module Searchable

  def self.included(searchable)
    searchable.class_eval do
      after_commit :enqueue_to_index
    end
  end

  def enqueue_to_index
    REDIS_GENERAL.sadd("search_index_#{self.class.to_s.underscore}", self.id)
  end

end
