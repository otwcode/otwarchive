class ResetBookmarkTagsJob < ApplicationJob
    queue_as :low

    def perform
        # Searches for non-canonical tags with zero usage count (only bookmarks or nothing)
        Tag.where(canonical: false, taggings_count_cache: 0).find_each(batch_size: 1000) do |tag|

            # Check if have associations (parents) or categorized types
            has_type = tag.type.present? && tag.type != 'Tag'
            has_parents = tag.common_taggings.exists?

            if has_type || has_parents
                # Removes data from the association table (Wrangling)
                tag.common_taggings.delete_all
                # Return the type to 'Tag' (status 'Unsorted')
                tag.update_column(:type, 'Tag')
            end
        end
    end
end