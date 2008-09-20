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
        tag = Tag.find_or_create_by_name(tag_name)
        unless tag.save
          tag.errors.full_messages.each { |err| self.errors.add_to_base(err)}
          raise
        end
        tag      
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
        if tag_string.is_a?(Array)
          tag_names = tag_string
        else
          tag_names = tag_string.split(ArchiveConfig.DELIMITER)
        end
        new_tags = tag_names.collect do |tag_name|
          tag_name.gsub!(/^\s*/, "")
          tag_name.gsub!(/\s*$/, "")
          tag = Tag.find(:first, :conditions => {:name => tag_name, :tag_category_id => category.id}) || Tag.new(:name => tag_name, :tag_category => category)
          if tag.new_record?
            unless tag.save 
              tag.errors.full_messages.each { |err| self.errors.add_to_base(err)}
              raise
            end
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
