  # note, if you modify this file you have to restart the server or console

module TaggingExtensions
  
  # returns an array of tag objects
  def tags(category=['all'])
    self.reload
    if category == ['all']
      Array(taggings.collect(&:valid_tag).compact)
    else
      a = category.collect do |c| 
        cat = TagCategory.find_by_name(c)
        return false unless cat
        taggings.find_by_category(cat).collect(&:valid_tag)
      end.flatten.compact
    end
  end
  
  # returns a delimited string of tag names
  def tag_string(category=['all'])
    self.reload
    if category == ['all']
      tags.map(&:name).sort.join(ArchiveConfig.DELIMITER)
    else
      (category.collect {|c| tags([c]).map(&:name)}).sort.join(ArchiveConfig.DELIMITER)
    end
  end

  # usage:
  # tag_with(:freeform => 'a, few, tags', :fandom => 'stargate atlantis', :rating => 'adult')
  # note, this replaces the tags in the categories given (and only in those categories)
  def tag_with(tag_category_hash)
    tag_category_hash.each_pair do |category, tag_string| 
      category = TagCategory.find_by_name(category.to_s)
      return false unless category
      # create the new tags
      if tag_string.blank?
        tag_array = []
      else
        new_tags = tag_string.split(ArchiveConfig.DELIMITER).collect do |tag_name|
          tag = Tag.find_or_create_by_name(tag_name)
          if tag.tag_category
            return false unless tag.tag_category == category
          else
            tag.tag_category = category
            tag.save
          end
          tag
        end
        tag_array = new_tags.flatten.compact
      end
      # add and remove tags to make the taggable's tags equal to the new tag_array
      self.reload
      current = tags(category.name)
      add = tag_array - current
      remove = current - tag_array
      add.each {|t| Tagging.create(:tag => t, :taggable => self) }
      remove.each {|t| self.taggings.find_by_tag(t).each(&:destroy)}
      self.tags
    end
  end
  
end
