class MakeTagsUniqueAcrossCategories < ActiveRecord::Migration

  def self.up
    Tag.reset_column_information
    by_name = Tag.all.group_by{|t| t.name.downcase}
    by_name.each do |name, tags|
      tags = tags.compact.uniq
      if tags.size > 1
        tags.each do |tag|
          # move bookmark tags to freeform
          unless tag.tag_category_id
            new_tag = Freeform.find_by_name(tag.name)
            if new_tag
              Tagging.find_all_by_tagger_id.each do |tagging|
                tagging.update_attribute(:tagger_id, new_tag.id)
              end
              tags.delete(tag)
              tag.destroy
            end
          end
        end
        if tags.size > 1
          # tag of first type gets to keep its name 
          # because it might be an official tag
          first = true
          Tag::TYPES.each do |type|
            tags.each do |tag|
              tag.update_attribute(:name, tag.name + " - " + tag[:type]) unless first
              tags.delete(tag)
              first = false
            end
          end
        end
      end
    end
 
    add_index :tags, ["name"], :name=> "index_tags_on_name", :unique => true
    remove_index :tags, :name => "index_tags_on_name_and_category", :unique => true
  end

  def self.down
    add_index :tags, ["name", "tag_category_id"], :name => "index_tags_on_name_and_category", :unique => true
    remove_index :tags, :name=> "index_tags_on_name"
  end
end
