module Creatable
  def self.included(creatable)
    creatable.class_eval do
      after_create :after_create
      before_update :before_update
      after_save :after_save
    end
  end

  def after_create
    notify_co_authors
    return unless !self.is_a?(Series) && self.posted?
    do_notify
  end

  def before_update
    notify_co_authors
    return unless !self.is_a?(Series) && self.valid? && self.posted?

    if self.posted_changed?
      do_notify
    else
      notify_subscribers_on_reveal
    end
  end

  def after_save
    if self.is_a?(Work)
      notify_recipients(self)
    end
  end

  # send the appropriate notifications
  def do_notify
    if self.is_a?(Work)
      notify_parents(self)
      notify_subscribers
      notify_prompters(self)
    elsif self.is_a?(Chapter) && self.position != 1
      notify_subscribers
    end
  end

  # Notify new co-authors that they've been added to a creation
  def notify_co_authors
    this_creation = self
    creation = self.work if self.is_a?(Chapter)
    if self && !self.authors.blank? && User.current_user.is_a?(User)
      new_authors = (self.authors - (self.pseuds + User.current_user.pseuds)).uniq
      unless new_authors.blank?
        for pseud in new_authors
          UserMailer.coauthor_notification(pseud.user.id, self.id, self.class.name).deliver
        end
      end
    end
    save_creatorships(this_creation)
  end

  # notify recipients that they have gotten a story!
  # we also need to check to see if the work is in a collection
  # only notify a recipient once for each work
  def notify_recipients(work)
    if work.posted && !work.new_recipients.blank? && !work.unrevealed?
      recipient_pseuds = Pseud.parse_bylines(work.new_recipients, assume_matching_login: true)[:pseuds]
      # check user prefs to see which recipients want to get gift notifications
      # (since each user has only one preference item, this removes duplicates)
      recip_ids = Preference.where(user_id: recipient_pseuds.map(&:user_id),
                                   recipient_emails_off: false).pluck(:user_id)
      recip_ids.each do |userid|
        if work.collections.empty? || work.collections.first.nil?
          UserMailer.recipient_notification(userid, work.id).deliver
        else
          UserMailer.recipient_notification(userid, work.id, work.collections.first.id).deliver
        end
      end
    end
  end

  # notify people subscribed to this creation or its authors
  def notify_subscribers
    work = self.respond_to?(:work) ? self.work : self
    if work && !work.unrevealed? && !work.anonymous?
      Subscription.for_work(work).each do |subscription|
        RedisMailQueue.queue_subscription(subscription, self)
      end
    end
  end

  # Check whether the work's creator has just been revealed (whether because
  # a collection has just revealed its works, or a collection has just revealed
  # creators). If so, queue up creator subscription emails.
  def notify_subscribers_on_reveal(work)
    # Double-check that it's a posted work.
    return unless work.is_a?(Work) && work.posted

    # Bail out if the work or its creator is currently unrevealed.
    return if work.in_anon_collection || work.in_unrevealed_collection

    # If we've reached here, the creator of the work must be public.
    # So now we want to check whether that's a recent thing.
    if work.in_anon_collection_changed? || work.in_unrevealed_collection_changed?
      # Prior to this save, the work was either anonymous or unrevealed.
      # Either way, the author was just revealed, so we should trigger
      # a creator subscription email.
      Subscription.where(
        subscribable_id: work.pseuds.pluck(:user_id),
        subscribable_type: "User"
      ).each do |subscription|
        RedisMailQueue.queue_subscription(subscription, work)
      end
    end
  end

  # notify prompters of response to their prompt
  def notify_prompters(work)
    if !work.challenge_claims.empty? && !work.unrevealed?
      if work.collections.first.nil?
        UserMailer.prompter_notification(work.id,).deliver
      else
        UserMailer.prompter_notification(work.id, work.collections.first.id).deliver
      end
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
    if self.nil?
      raise "Bad creation..."
    end
    if !self.authors.blank?
      new_authors = (self.authors - self.pseuds).uniq
      new_authors.each do |pseud|
        self.pseuds << pseud
        if self.is_a?(Chapter) && self.work
          self.work.pseuds << pseud unless self.work.pseuds.include?(pseud)
        elsif self.is_a?(Work)
          if self.chapters.first
            self.chapters.first.pseuds << pseud unless self.chapters.first.pseuds.include?(pseud)
          end
          self.series.each { |series| series.pseuds << pseud unless series.pseuds.include?(pseud) }
        end
      end
    end
    unless self.authors_to_remove.blank?
      self.pseuds.delete(self.authors_to_remove)
      if self.is_a?(Work)
        self.chapters.first.pseuds.delete(self.authors_to_remove)
      end
    end
  end
end
