class ResetBookmarkTagsJob < ApplicationJob
  queue_as :low

  def perform(tag_ids)
    base_scope = Tag.nonsynonymous
                    .where(canonical: false)
                    .where("NOT EXISTS (
                      SELECT 1 FROM taggings 
                      WHERE taggings.tagger_id = tags.id 
                      AND taggings.taggable_type IN ('Work', 'ExternalWork')
                    )")
    
    base_scope.where(id: tag_ids).each do |tag|
      has_type = tag.type.present? && tag.type != "Tag"
      has_parents = tag.common_taggings.exists?
      
      next unless has_type || has_parents
        
      tag.common_taggings.destroy_all
      tag.update(type: "Tag")
    end
  end
end
