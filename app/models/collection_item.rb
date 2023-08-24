class CollectionItem < ApplicationRecord
  APPROVAL_OPTIONS = [
    ["", :unreviewed],
    [ts("Approved"), :approved],
    [ts("Rejected"), :rejected]
  ]

  belongs_to :collection, inverse_of: :collection_items, autosave: false
  belongs_to :item, polymorphic: :true, inverse_of: :collection_items, touch: true

  validates :collection_id, uniqueness: { scope: [:item_id, :item_type] }

  enum user_approval_status: {
    rejected: -1,
    unreviewed: 0,
    approved: 1
  }, _suffix: :by_user

  enum collection_approval_status: {
    rejected: -1,
    unreviewed: 0,
    approved: 1
  }, _suffix: :by_collection

  validate :collection_must_exist, on: :create
  def collection_must_exist
    if collection.nil?
      errors.add(:collection, :blank)
    elsif collection.new_record?
      errors.add(:collection, :not_found, name: collection.name)
    end
  end

  validate :collection_is_open, on: :create
  def collection_is_open
    return unless collection.present? && collection.closed? &&
                  !collection.user_is_maintainer?(User.current_user)

    errors.add(:collection, :closed, title: collection.title)
  end

  scope :include_for_works, -> { includes(item: :pseuds) }
  scope :unrevealed, -> { where(unrevealed: true) }
  scope :anonymous, -> { where(anonymous:  true) }

  def self.for_user(user=User.current_user)
    # get ids of user's bookmarks and works
    bookmark_ids = Bookmark.joins(:pseud).where("pseuds.user_id = ?", user.id).pluck(:id)
    work_ids = Work.joins(:pseuds).where("pseuds.user_id = ?", user.id).pluck(:id)
    # now return the relation
    where("(item_id IN (?) AND item_type = 'Work') OR (item_id IN (?) AND item_type = 'Bookmark')", work_ids, bookmark_ids)
  end

  scope :invited_by_collection, -> { approved_by_collection.unreviewed_by_user }
  scope :approved_by_both, -> { approved_by_collection.approved_by_user }

  before_validation :set_anonymous_and_unrevealed, on: :create
  def set_anonymous_and_unrevealed
    return unless collection

    self.unrevealed = collection.unrevealed?
    self.anonymous = collection.anonymous?
  end

  def destroyed_by_item?
    item && destroyed_by_association &&
      item.association(:collection_items).reflection == destroyed_by_association
  end

  after_save :update_work
  after_destroy :update_work, unless: :destroyed_by_item?

  # Set associated works to anonymous or unrevealed as appropriate.
  def update_work
    return unless item.is_a?(Work) && item.persisted?

    item.set_anon_unrevealed

    item.save!(validate: false) if item.will_save_change_to_anonymous? ||
                                   item.will_save_change_to_unrevealed?
  end

  # Poke the item if it's just been approved or unapproved so it gets picked up by the search index
  after_save :reindex_item
  after_destroy :reindex_item, unless: :destroyed_by_item?
  def reindex_item
    item&.enqueue_to_index
  end

  after_create_commit :notify_of_association
  def notify_of_association
    email_notify = self.collection.collection_preference &&
                    self.collection.collection_preference.email_notify

    if email_notify && !self.collection.email.blank?
      CollectionMailer.item_added_notification(item_id, collection_id, item_type).deliver_later
    end
  end

  after_create_commit :notify_archivist_added
  # Sends emails to item creator(s) in the case that an archivist
  # has added them to the collection.
  def notify_archivist_added
    return unless User.current_user&.archivist && collection.user_is_maintainer?(User.current_user)

    item.users.each do |email_recipient|
      next if email_recipient.preference.collection_emails_off

      UserMailer.archivist_added_to_collection_notification(
        email_recipient.id,
        item.id,
        collection.id
      ).deliver_later
    end
  end

  before_validation :approve_automatically, on: :create
  def approve_automatically
    return unless item && collection

    # approve with the current user, who is the person who has just
    # added this item -- might be either moderator or owner
    approve(User.current_user)

    # if the collection is open or the user who owns this work is a member, go ahead and approve
    # for the collection
    return if approved_by_collection?

    approve_by_collection if !collection.moderated? ||
                             collection.user_is_posting_participant?(User.current_user)
  end

  before_save :send_work_invitation
  def send_work_invitation
    if !approved_by_user? && approved_by_collection? && self.new_record?
      if !User.current_user.is_author_of?(item)
        # a maintainer is attempting to add this work to their collection
        # so we send an email to all the works owners
        item.users.each do |email_author|
          unless email_author.preference.collection_emails_off
            UserMailer.invited_to_collection_notification(email_author.id, item.id, collection.id).deliver_now
          end
        end
      end
    end
  end

  after_destroy :expire_caches
  def expire_caches
    if self.item.respond_to?(:expire_caches)
      self.item.expire_caches
      CacheMaster.record(item_id, 'collection', collection_id)
    end
  end

  attr_writer :remove
  def remove
    @remove || ""
  end

  def recipients
    item.respond_to?(:recipients) ? item.recipients : ""
  end

  def item_creator_pseuds
    if self.item
      if self.item.respond_to?(:pseuds)
        self.item.pseuds
      elsif self.item.respond_to?(:pseud)
        [self.item.pseud]
      else
        []
      end
    else
      []
    end
  end

  def item_date
    item.respond_to?(:revised_at) ? item.revised_at : item.updated_at
  end

  def user_allowed_to_destroy?(user)
    user.is_author_of?(self.item) ||
      (self.collection.user_is_maintainer?(user) && !self.rejected_by_user?)
  end

  def approve_by_user
    self.user_approval_status = :approved
  end

  def approve_by_collection
    self.collection_approval_status = :approved
  end

  def approved?
    approved_by_user? && approved_by_collection?
  end

  def approve(user)
    if user.nil?
      # this is being run via rake task eg for importing collections
      approve_by_user
      approve_by_collection
    else
      author_of_item = user.is_author_of?(item) || (user == User.current_user && item.new_record?)
      archivist_maintainer = user.archivist && self.collection.user_is_maintainer?(user)
      approve_by_user if author_of_item || archivist_maintainer
      approve_by_collection if self.collection.user_is_maintainer?(user)
    end
  end

  def posted?
    self.item.respond_to?(:posted?) ? self.item.posted? : true
  end

  def notify_of_reveal
    unless self.unrevealed? || !self.posted?
      recipient_pseuds = Pseud.parse_bylines(self.recipients)[:pseuds]
      recipient_pseuds.each do |pseud|
        unless pseud.user.preference.recipient_emails_off
          UserMailer.recipient_notification(pseud.user.id, self.item.id, self.collection.id).deliver_after_commit
        end
      end

      # also notify prompters of responses to their prompt
      if item_type == "Work" && !item.challenge_claims.blank?
        UserMailer.prompter_notification(self.item.id, self.collection.id).deliver_after_commit
      end

      # also notify the owners of any parent/inspired-by works
      if item_type == "Work" && !item.parent_work_relationships.empty?
        item.parent_work_relationships.each do |relationship|
          relationship.notify_parent_owners
        end
      end
    end
  end

  after_update :notify_of_unrevealed_or_anonymous
  def notify_of_unrevealed_or_anonymous
    # This CollectionItem's anonymous/unrevealed status can only affect the
    # item's status if (a) the CollectionItem is approved by the user and (b)
    # the item is a work. (Bookmarks can't be anonymous/unrevealed at the
    # moment.)
    return unless approved_by_user? && item.is_a?(Work)

    # Check whether anonymous/unrevealed is becoming true, when the work
    # currently has it set to false:
    newly_anonymous = (saved_change_to_anonymous?(to: true) && !item.anonymous?)
    newly_unrevealed = (saved_change_to_unrevealed?(to: true) && !item.unrevealed?)

    return unless newly_unrevealed || newly_anonymous

    # Don't notify if it's one of the work creators who is changing the work's
    # status.
    return if item.users.include?(User.current_user)

    item.users.each do |user|
      UserMailer.anonymous_or_unrevealed_notification(
        user.id, item.id, collection.id,
        anonymous: newly_anonymous, unrevealed: newly_unrevealed
      ).deliver_after_commit
    end
  end
end
