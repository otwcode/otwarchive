# note, if you modify this file you have to restart the server or console

module TaggingExtensions
  
  # returns an array of (valid) tag objects
  # accepts either a category object, or a category name
  def tags(category='all')
    if category == 'all'
      tags = taggings.collect(&:valid_tag)
    else 
      category = TagCategory.find_by_name(category) if category.is_a?(String)
      return false unless category.is_a?(TagCategory)
      tags = []
      if category == TagCategory.default  # ambiguous tags get retrieved into the default category
         tags << taggings.find_by_category(TagCategory.ambiguous).collect(&:valid_tag)
      end
      tags << taggings.find_by_category(category).collect(&:valid_tag)
    end
    tags.flatten.compact
  end
  
  # returns a delimited string of tag names
  # accepts either a category object, or a category name
  def tag_string(category='all')    
    if category.is_a?(TagCategory) 
      tags.valid.by_category(category).map(&:name).sort.join(ArchiveConfig.DELIMITER)
    elsif TagCategory.find_by_name(category)
      tags.valid.by_category(TagCategory.find_by_name(category)).map(&:name).sort.join(ArchiveConfig.DELIMITER)
    else
      tags.valid.map(&:name).sort.join(ArchiveConfig.DELIMITER)
    end
  end

  # for use on objects which don't care about categories (currently bookmarks)
  # tag_string('a, few, tags')
  def tag_string=(tag_string)
    if tag_string.blank?
      tag_array = []
    else
      new_tags = tag_string.split(ArchiveConfig.DELIMITER).collect do |tag_name|
        Tag.find_or_create_by_name(tag_name)
      end
      tag_array = new_tags.flatten.compact
    end
    # add and remove tags to make the taggable's tags equal to the new tag_array
    current = tags
    add = tag_array - current
    remove = current - tag_array
    add.each {|t| Tagging.create(:tag => t, :taggable => self) }
    remove.each {|t| self.taggings.find_by_tag(t).each(&:destroy)}
    tag_array
  end

  # for use on objects which care about categories (currently works)
  # tag_with(:default => 'a, few, tags', :fandom => 'stargate atlantis', :rating => 'adult')
  # note, this replaces the tags and sets new_tags only for the categories given
  # it doesn't do error checking to ensure that the category set is accurate or complete
  def tag_with(tag_category_hash)
    new_tags = []
    tag_category_hash.each_pair do |category, tag_string| 
      category = TagCategory.find_by_name(category.to_s)
      return false unless category
      # create the new tags
      if tag_string.blank?
        tag_array = []
      else
        new_tags = tag_string.split(ArchiveConfig.DELIMITER).collect do |tag_name|
          tag_name.gsub!(/^\s*/, "")
          tag_name.gsub!(/\s*$/, "")
          tag = Tag.find_or_create_by_name(tag_name)
          if tag.tag_category == nil
            tag.tag_category = category
            tag.save 
          elsif tag.tag_category == TagCategory.ambiguous
            #TODO pop up a warning - add a special tag to the array?
          elsif tag.tag_category != category
             return false  # can't reassign a tag from within tag_with
          end
          tag
        end
        tag_array = new_tags.flatten.compact
      end
      new_tags << tag_array
      # add and remove tags to make the taggable's tags equal to the new tag_array
      current = tags.by_category(category)
      add = tag_array - current
      remove = current - tag_array
      add.each {|t| Tagging.create(:tag => t, :taggable => self) }
      remove.each {|t| self.taggings.find_by_tag(t).each(&:destroy)}
    end
    self.new_tags = new_tags.flatten
  end
  
end
