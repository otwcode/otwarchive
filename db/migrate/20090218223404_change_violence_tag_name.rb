class ChangeViolenceTagName < ActiveRecord::Migration
  def self.up
    @old = Tag.find_by_name('Extreme Violence')
    @new = Tag.find_by_name('Graphic Depictions of Violence')
    if @old.is_a?(Warning) # @old exists
      if !@new  # @new doesn't exist yet
        # give @old the new name
        @old.update_attribute(:name, 'Graphic Depictions of Violence')
      else  # @new exists
        if @new.taggings.count == 0 # but hasn't been used yet
          @new.destroy # get rid of new, and rename old
          @old.update_attribute(:name, 'Graphic Depictions of Violence')
        else # and has been used
          # change all works that use old to use new instead
          @old.works.each do |work|  
            work.warnings = work.warnings + [@new] - [@old]
            work.common_tags = work.common_tags  + [@new] - [@old]
          end
          # destroy old
          if @old.taggings.count == 0
             @old.destroy
          else
             raise "didn't work, please fix database by hand"
          end
        end
      end
    end
  end

  def self.down
  end
end
