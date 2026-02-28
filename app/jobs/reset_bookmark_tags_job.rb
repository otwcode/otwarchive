class ResetBookmarkTagsJob < ApplicationJob
  queue_as :low

  def perform(tag_ids = nil)
    base_scope = Tag.nonsynonymous.where(taggings_count_cache: 0)

    if tag_ids.nil?
      base_scope.find_in_batches(batch_size: 1000) do |tags|
        ResetBookmarkTagsJob.perform_later(tags.map(&:id))
      end
    else
      base_scope.where(id: tag_ids).each do |tag|
        has_type = tag.type.present? && tag.type != "Tag"
        has_parents = tag.common_taggings.exists?

        next unless has_type || has_parents
        
        tag.common_taggings.destroy_all
        tag.update(type: "Tag")
      end
    end
  end
end
