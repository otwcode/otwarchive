module UserOwnedObjects
  
  # fetch all creations a user own (via pseuds)
  def creations
    pseuds.collect(&:creations).reject(&:empty?).flatten
  end
  
  # Find all works for a given user
  def works
    Work.find(:all, :conditions => ["creatorships.pseud_id IN (?)", self.pseuds.collect(&:id).to_s], :include => :creatorships)  
  end
  
  # Find all chapters for a given user
  def chapters
    Chapter.find(:all, :conditions => ["creatorships.pseud_id IN (?)", self.pseuds.collect(&:id).to_s], :include => :creatorships)  
  end
  
  # Get the total number of works for a given user
  def work_count
    Work.count(:all, :conditions => ["creatorships.pseud_id IN (?)", self.pseuds.collect(&:id).to_s], :include => :creatorships)
  end 
  
  # Returns an array (of pseuds) of this user's co-authors
  def coauthors
     creations.collect(&:pseuds).flatten.uniq - pseuds
  end
  
  # Gets the user's one allowed unposted work
  def unposted_work
    creations.select{|c| c.class == Work && c.posted != true}.first
  end
  
  # Gets the user's one allowed unposted chapter per work
  def unposted_chapter(work)
    creations.select{|c| c.class == Chapter && c.work_id == work.id && c.posted != true}.first
  end 
  
  # Find all comments for a given user
  def comments
    Comment.find(:all, :conditions => ["pseud_id IN (?)", self.pseuds.collect(&:id).to_s])
  end
  
  # TODO: Needs refinement!
  # Find all comments left on things that belong to this user
  def feedback
     fb = ([self] + chapters + comments).collect(&:comments).reject(&:empty?).flatten
     fb.sort {|x,y| y.created_at <=> x.created_at }.uniq
  end
  
end