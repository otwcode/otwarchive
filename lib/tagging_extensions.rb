class ActiveRecord::Base
  # note, if you modify this file you have to restart the server or console

  module TaggingExtensions
    # Replace the existing tags on self given a string of delimited names 
    def tag_with name_string
      return false unless name_string.is_a? String
      name_array = name_string.split(ArchiveConfig.DELIMITER).map {|name| name.strip.squeeze(" ")}
      name_array = name_array - [""]
      current = tags.map(&:name)
      tag_add(name_array - current)
      tag_del(current - name_array)
      return true
   end

   # Returns the tags on self as a string.
    def tag_string
      self.reload
      tags.map(&:name).sort.join(ArchiveConfig.DELIMITER)
    end

    # current official tags: Fandoms, Characters, Ratings, Warnings
    
    # return the fandom tags as a string
    def fandoms
      tags.select{|t| t.is_fandom? }.map(&:name).sort.join(ArchiveConfig.DELIMITER)
    end
    
    # return the character tags as a string
    def characters
      if self.is_a?(Label) && self.is_fandom?
        taggers.select{|t| t.is_character? }.map(&:name).sort.join(ArchiveConfig.DELIMITER)
      else
       tags.select{|t| t.is_character? }.map(&:name).sort.join(ArchiveConfig.DELIMITER)
      end
    end
    
    # return the ratings tags as a string
    def ratings
      tags.select{|t| t.is_rating? }.map(&:name).sort.join(ArchiveConfig.DELIMITER)
    end

    # return the ratings tags as a string
    def warnings
      tags.select{|t| t.is_warning? }.map(&:name).sort.join(ArchiveConfig.DELIMITER)
    end
    
    # return unofficial tags as a string
    def freeforms
      alltags = self.tags.select{|t| t.is_freeform? }.map(&:name)
      others = [self.fandoms, self.characters, self.ratings, self.warnings].join(ArchiveConfig.DELIMITER)
      others = others.split(ArchiveConfig.DELIMITER)
      (alltags - others).sort.join(ArchiveConfig.DELIMITER)
    end

    private 

    # Add tags to self.
    def tag_add incoming
      incoming.each do |tag_name|
        begin
          tag = Label.find_or_create_by_name(tag_name)
          raise Label::Error, "tag could not be saved: #{tag_name}" if tag.new_record?
          tag.taggers << self unless tag.is_banned?
        rescue ActiveRecord::StatementInvalid => e
          raise unless e.to_s =~ /duplicate/i
        end
      end
    end
  
    # Removes tags from self. 
    def tag_del outgoing
      tags.delete(*(tags.select do |tag|
        outgoing.include? tag.name    
      end))
      end

  end
  
  include TaggingExtensions
end
