class CreationObserver < ActiveRecord::Observer
  observe Chapter, Work, Series

  # Send notifications when a creation is posted without preview
  def after_create(creation)
    notify_co_authors(creation)
    return unless !creation.is_a?(Series) && creation.posted?
    if creation.is_a?(Work)
      notify_recipients(creation)
      notify_parents(creation)
      notify_subscribers(creation)
      notify_prompters(creation)
    elsif creation.is_a?(Chapter) && creation.position != 1
      notify_subscribers(creation)
    end
  end

  # Send notifications when a creation is posted from a draft state
  def before_update(creation)
    notify_co_authors(creation)
    return unless !creation.is_a?(Series) && creation.valid? && creation.posted_changed? && creation.posted?
    if creation.is_a?(Work)
      notify_recipients(creation)
      notify_parents(creation)
      notify_subscribers(creation)
      notify_prompters(creation)
    elsif creation.is_a?(Chapter) && creation.position != 1
      notify_subscribers(creation)
    end
  end

  # Notify new co-authors that they've been added to a creation
  def notify_co_authors(creation)
    this_creation = creation
    creation = creation.work if creation.is_a?(Chapter)
    if creation && !creation.authors.blank? && User.current_user.is_a?(User)
      new_authors = (creation.authors - (creation.pseuds + User.current_user.pseuds)).uniq
      unless new_authors.blank?
        for pseud in new_authors
          UserMailer.coauthor_notification(pseud.user.id, creation.id, creation.class.name).deliver
        end
      end
    end
    save_creatorships(this_creation)
  end

  # notify recipients that they have gotten a story!
  def notify_recipients(work)
    if !work.recipients.blank? && !work.unrevealed?
      recipient_pseuds = Pseud.parse_bylines(work.recipients, :assume_matching_login => true)[:pseuds]
      recipient_pseuds.each do |pseud|
        UserMailer.recipient_notification(pseud.user.id, work.id).deliver
      end
    end
  end

  # notify people subscribed to this creation or its authors
  def notify_subscribers(creation)
    work = creation.respond_to?(:work) ? creation.work : creation
    if work && !work.unrevealed? && !work.anonymous?
      Subscription.for_work(work).each do |subscription|
        UserMailer.subscription_notification(subscription.user.id, subscription.id, creation.id, creation.class.name).deliver
      end
    end
  end

  # notify prompters of response to their prompt
  def notify_prompters(work)
    if !work.challenge_claims.empty? && !work.unrevealed?
      UserMailer.prompter_notification(work.id).deliver
    end
  end

  # notify authors of related work
  def notify_parents(work)
    if !work.parent_work_relationships.empty? && !work.unrevealed?
      work.parent_work_relationships.each {|relationship| relationship.notify_parent_owners}
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
    unless creation.authors_to_remove.blank?
      creation.pseuds.delete(creation.authors_to_remove)
      if creation.is_a?(Work)
        creation.chapters.first.pseuds.delete(creation.authors_to_remove)
      end
    end
  end

end
