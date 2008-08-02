module UserOwnedObjects
  
  # fetch all creations a user own (via pseuds)
  def creations
    pseuds.collect(&:creations).reject(&:empty?).flatten
  end
  
  # Find all works for a given user
  def works(current_user=false)
    visibility = " AND posted=1"
    visibility += " AND restricted=0" unless current_user.is_a?(User)
    Work.find(:all, :include => :creatorships, :conditions => ["creatorships.pseud_id IN (?)" + visibility, pseuds.collect(&:id).join(",")])
  end
  
  # Find all chapters for a given user
  def chapters
    Chapter.find(:all, :include => :creatorships, :conditions => ["creatorships.pseud_id IN (?)", pseuds.collect(&:id).join(",")])  
  end
  
  # Find all series for a given user
  def series
    Series.find(:all, :include => :creatorships, :conditions => ["creatorships.pseud_id IN (?)", pseuds.collect(&:id).join(",")])  
  end
  
  # Get the total number of series for a given user
  def series_count
    Series.count(:all, :include => :creatorships, :conditions => ["creatorships.pseud_id IN (?)", pseuds.collect(&:id).join(",")])  
  end
  
  # Get the total number of works for a given user
  def work_count(current_user=false)
    visibility = " AND posted=1"
    visibility += " AND restricted=0" unless current_user.is_a?(User)
		Work.count(:all, :include => :creatorships, :conditions => ["creatorships.pseud_id IN (?)" + visibility, pseuds.collect(&:id).join(",")])
	end  
  
  # Returns an array (of pseuds) of this user's co-authors
  def coauthors
     creations.collect(&:pseuds).flatten.uniq - pseuds
  end
  
  # Gets the user's one allowed unposted work
  def unposted_work
    works.select{|w| w.posted != true}.first
  end
  
  # Gets the user's one allowed unposted chapter per work
  def unposted_chapter(work)
    chapters.select{|c| c.work_id == work.id && c.posted != true}.first
  end 
  
  # Find all comments for a given user
  def comments
    Comment.find(:all, :conditions => ["pseud_id IN (?)", self.pseuds.collect(&:id).to_s])
  end
  
end