class CreationObserver < ActiveRecord::Observer
  observe Chapter, Work, Series

  def after_save(creation)
    # Notify new co-authors that they've been added to a creation
    this_creation = creation
    creation = creation.class == Series ? creation : (creation.class == Chapter ? creation.work : creation)
    if creation && !creation.authors.blank? && User.current_user.is_a?(User)
      new_authors = (creation.authors - (creation.pseuds + User.current_user.pseuds)).uniq
      unless new_authors.blank?
        for pseud in new_authors
          UserMailer.coauthor_notification(pseud.user, creation).deliver
        end
      end
    end
    save_creatorships(this_creation)
  end
  
  def before_update(new_work)
    return unless new_work.class == Work && new_work.valid?
    old_work = Work.find(new_work)
    if !old_work.posted && new_work.posted
      # newly-posted
      
      # notify recipients that they have gotten a story!
      if !new_work.recipients.blank? && !new_work.unrevealed?
        recipient_pseuds = Pseud.parse_bylines(new_work.recipients, :assume_matching_login => true)[:pseuds]
        recipient_pseuds.each do |pseud|
          UserMailer.recipient_notification(pseud.user, new_work).deliver
        end
      end
      
      # notify authors of related work
      if !new_work.parent_work_relationships.empty? && !new_work.unrevealed?
        new_work.parent_work_relationships.each {|relationship| relationship.notify_parent_owners}
      end
      
    end
  end
  
  # Save creatorships after the creation is saved
  def save_creatorships(creation)
    if creation.nil?
      raise "Bad creation..."
    end
    if !creation.authors.blank?
      new_authors = (creation.authors - creation.pseuds).uniq
      new_authors.each do |pseud|
        creation.pseuds << pseud
        if creation.is_a?(Chapter) && creation.work
          creation.work.pseuds << pseud unless creation.work.pseuds.include?(pseud)
        elsif creation.is_a?(Work)
          if creation.chapters.first
            creation.chapters.first.pseuds << pseud unless creation.chapters.first.pseuds.include?(pseud)
          end
          creation.series.each { |series| series.pseuds << pseud unless series.pseuds.include?(pseud) }      
        end
      end
    end
    if creation.toremove
      creation.pseuds.delete(creation.toremove)
      if creation.is_a?(Work)
        creation.chapters.first.pseuds.delete(creation.toremove)
      end
    end
  end
  
end
