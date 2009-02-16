class MakeTagsUniqueAcrossCategories < ActiveRecord::Migration

  def self.up
    Tag.reset_column_information
    # give media tags a fake high tagging count
    Media.all.each { |m| Tag.update_counters m.id, :taggings_count => 10000 }
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
          # have the tag with the most works keep its name. in a tie, chose the earliest
          ordered_tags = tags.sort_by { |t| [ (10000 - t.taggings_count), t.id ] }
          second = false
          ordered_tags.each do |tag|
            if second
              tag.update_attribute(:name, tag.name + " - " + tag[:type])
            else
              second = true
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
