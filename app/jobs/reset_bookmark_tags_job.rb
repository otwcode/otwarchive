class ResetBookmarkTagsJob < ApplicationJob
  queue_as :low

  def perform(tag_ids = nil)
    # Maintains the use of "canonical: false" to avoid clearing official tags with 0 works
    base_scope = Tag.nonsynonymous.where(canonical: false, taggings_count_cache: 0)

    # Searches for non-canonical tags with zero usage count (only bookmarks or nothing)
    if tag_ids.nil?
      # Find the tags and divide them into smaller batches
      base_scope.find_in_batches(batch_size: 1000) do |tags|
        ResetBookmarkTagsJob.perform_later(tags.map(&:id))
      end
    else
      # Takes the batch of IDs received and processes them
      base_scope.where(id: tag_ids).each do |tag|
        # Check if have associations (parents) or categorized types
        has_type = tag.type.present? && tag.type != "Tag"
        has_parents = tag.common_taggings.exists?

        # Skip to the next tag if don't need cleaning
        next unless has_type || has_parents
        
        # Cleans up calling callbacks methods
        tag.common_taggings.destroy_all
        tag.update(type: "Tag")
      end
    end
  end
end
