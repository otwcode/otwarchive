class CreationObserver < ActiveRecord::Observer
  observe Chapter, Work, Series

  # Notify new co-authors that they've been added to a work
  def after_save(creation)
    work = creation.class == Chapter ? creation.work : creation
    if !creation.authors.blank? && User.current_user.is_a?(User)
      new_authors = (creation.authors - (work.pseuds + User.current_user.pseuds)).uniq
      unless new_authors.blank?
        for pseud in new_authors
          UserMailer.deliver_coauthor_notification(pseud.user, work)
        end
      end
    end
    save_creatorships(creation)
  end
  
  # Save creatorships after the creation is saved
  def save_creatorships(creation)
    if !creation.authors.blank?
      new_authors = (creation.authors - creation.pseuds).uniq
      new_authors.each do |pseud|
        creation.pseuds << pseud
        if creation.is_a?(Chapter)
          creation.work.pseuds << pseud unless creation.work.pseuds.include?(pseud)
        elsif creation.is_a?(Work)
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
