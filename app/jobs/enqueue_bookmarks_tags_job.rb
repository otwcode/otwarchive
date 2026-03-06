class EnqueueBookmarksTagsJob < ApplicationJob
  queue_as :low

  def perform
    base_scope = Tag.nonsynonymous.where(taggings_count_cache: 0)
      
    base_scope.find_in_batches(batch_size: 1000) do |tags|
      ResetBookmarkTagsJob.perform_later(tags.map(&:id))
    end
  end
end
