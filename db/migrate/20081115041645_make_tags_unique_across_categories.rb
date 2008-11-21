class MakeTagsUniqueAcrossCategories < ActiveRecord::Migration

  def self.up
    Tag.reset_column_information
    by_name = Tag.all.group_by{|t| t.name.downcase}
    by_name.each do |name, tags|
      if tags.size > 1
        tags.each do |tag|
          if tag.taggings_count==0
            tags.delete(tag)
            tag.destroy 
          end
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
          tags.each do |tag|
            tag.update_attribute(:name, tag.name + " - " + tag[:type])
          end
          Ambiguity.create!(:name => name)
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
