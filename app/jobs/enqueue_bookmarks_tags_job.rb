class EnqueueBookmarksTagsJob < ApplicationJob
  queue_as :low

  def perform
    base_scope = Tag.nonsynonymous
                    .where(canonical: false)
                    .where("NOT EXISTS (
                      SELECT 1 FROM taggings 
                      WHERE taggings.tagger_id = tags.id 
                      AND taggings.taggable_type IN ('Work', 'ExternalWork')
                    )")
                    .limit(5000)
                    .pluck(:id)
      
    base_scope.each_slice(1000) do |batch_ids|
      ResetBookmarkTagsJob.perform_later(batch_ids)
    end
  end
end
