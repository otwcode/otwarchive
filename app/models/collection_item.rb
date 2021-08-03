class CollectionItem < ApplicationRecord
  include ActiveModel::ForbiddenAttributesProtection

  NEUTRAL = 0
  APPROVED = 1
  REJECTED = -1

  LABEL = {}
  LABEL[NEUTRAL] = ""
  LABEL[APPROVED] = ts("Approved")
  LABEL[REJECTED] = ts("Rejected")

  APPROVAL_OPTIONS = [ [LABEL[NEUTRAL], NEUTRAL],
                       [LABEL[APPROVED], APPROVED],
                       [LABEL[REJECTED], REJECTED] ]

  belongs_to :collection, inverse_of: :collection_items
  belongs_to :item, polymorphic: :true, inverse_of: :collection_items, touch: true
  belongs_to :work,  class_name: "Work", foreign_key: "item_id", inverse_of: :collection_items
  belongs_to :bookmark, class_name: "Bookmark", foreign_key: "item_id"

  has_many :approved_collections, -> {
    where('collection_items.user_approval_status = ? AND collection_items.collection_approval_status = ?', CollectionItem::APPROVED, CollectionItem::APPROVED)
   }, through: :collection_items, source: :collection

  validates_uniqueness_of :collection_id, scope: [:item_id, :item_type],
    message: ts("already contains this item.")

  validates_numericality_of :user_approval_status, allow_blank: true, only_integer: true
  validates_inclusion_of :user_approval_status, in: [-1, 0, 1], allow_blank: true,
    message: ts("is not a valid approval status.")

  validates_numericality_of :collection_approval_status, allow_blank: true, only_integer: true
  validates_inclusion_of :collection_approval_status, in: [-1, 0, 1], allow_blank: true,
    message: ts("is not a valid approval status.")

  validate :collection_is_open, on: :create
  def collection_is_open
    if self.new_record? && self.collection && self.collection.closed? && !self.collection.user_is_maintainer?(User.current_user)
      errors.add(:base, ts("The collection %{title} is not currently open.", title: self.collection.title))
    end
  end

  scope :include_for_works, -> { includes(work: :pseuds)}
  scope :unrevealed, -> { where(unrevealed: true) }
  scope :anonymous, -> { where(anonymous:  true) }

  def self.for_user(user=User.current_user)
    # get ids of user's bookmarks and works
    bookmark_ids = Bookmark.joins(:pseud).where("pseuds.user_id = ?", user.id).pluck(:id)
    work_ids = Work.joins(:pseuds).where("pseuds.user_id = ?", user.id).pluck(:id)
    # now return the relation
    where("(item_id IN (?) AND item_type = 'Work') OR (item_id IN (?) AND item_type = 'Bookmark')", work_ids, bookmark_ids)
  end

  def self.approved_by_user
    where(user_approval_status: APPROVED)
  end

  def self.rejected_by_user
    where(user_approval_status: REJECTED)
  end

  def self.unreviewed_by_user
    where(user_approval_status: NEUTRAL)
  end

  def self.approved_by_collection
    where(collection_approval_status: APPROVED).where(user_approval_status: APPROVED)
  end

  def self.invited_by_collection
    where(collection_approval_status: APPROVED).where(user_approval_status: NEUTRAL)
  end

  def self.rejected_by_collection
    where(collection_approval_status: REJECTED)
  end

  def self.unreviewed_by_collection
    where(collection_approval_status: NEUTRAL)
  end

  before_save :set_anonymous_and_unrevealed
  def set_anonymous_and_unrevealed
    if self.new_record? && collection
      self.unrevealed = true if collection.reload.unrevealed?
      self.anonymous = true if collection.reload.anonymous?
    end
  end

  after_save :update_work
  after_destroy :update_work

  # Set associated works to anonymous or unrevealed as appropriate.
  #
  # Inverses are set up properly on self.item, so we use that field to check
  # whether we're currently in the process of saving a brand new work, or
  # whether the work is in the process of being destroyed. (In which case we
  # rely on the Work's callbacks to set anon/unrevealed status properly.) But
  # because we want to discard changes made in preview mode, we perform the
  # actual anon/unrevealed updates on self.work, which doesn't have proper
  # inverses and therefore is freshly loaded from the database.
  def update_work
    return unless item.is_a?(Work) && item.persisted? && !item.saved_change_to_id?

    if work.present?
      work.update_anon_unrevealed

      # For a more helpful error message, raise an error saying that the work
      # is invalid if we fail to save it.
      raise ActiveRecord::RecordInvalid, work unless work.save(validate: false)
    end
  end

  # Poke the item if it's just been approved or unapproved so it gets picked up by the search index
  after_update :update_item_for_status_change
  def update_item_for_status_change
    if saved_change_to_user_approval_status? || saved_change_to_collection_approval_status?
      item.save!
    end
  end

  after_create_commit :notify_of_association
  def notify_of_association
    email_notify = self.collection.collection_preference &&
                    self.collection.collection_preference.email_notify

    if email_notify && !self.collection.email.blank?
      CollectionMailer.item_added_notification(item_id, collection_id, item_type).deliver_later
    end
  end

  before_save :approve_automatically
  def approve_automatically
    if self.new_record?
      # approve with the current user, who is the person who has just
      # added this item -- might be either moderator or owner
      approve(User.current_user == :false ? nil : User.current_user)

      # if the collection is open or the user who owns this work is a member, go ahead and approve
      # for the collection
      if !approved_by_collection? && collection
        if !collection.moderated? || collection.user_is_maintainer?(User.current_user) || collection.user_is_posting_participant?(User.current_user)
          approve_by_collection
        end
      end

      # if at least one of the owners of the items automatically approves
      # adding, go ahead and approve by user
      if !approved_by_user?
        case item_type
        when "Work"
          users = item.users || [User.current_user] # if the work has no users, it is also new and being created by the current user
        when "Bookmark"
          users = [item.pseud.user] || [User.current_user]
        end

        users.each do |user|
          if user.preference.automatically_approve_collections
            # if the work is being added by a collection maintainer and at
            # least ONE of the works owners allows automatic inclusion in
            # collections, add the work to the collection
            approve_by_user
            users.each do |email_user|
              unless email_user.preference.collection_emails_off
                UserMailer.added_to_collection_notification(email_user.id, item.id, collection.id).deliver_now
              end
            end
            break
          end
        end
      end
    end
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

  after_update :notify_of_status_change
  def notify_of_status_change
    if saved_change_to_unrevealed? && item.respond_to?(:new_recipients)
      # making sure notify_recipients in the work model has not already notified
      if item.new_recipients.present?
        notify_of_reveal
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

  def check_gift_received(has_received)
    item_creator_pseuds.map {|pseud|
      has_received[pseud.name] ? "Y" :
        (pseud.user.pseuds.collect(&:name).flatten & has_received.keys).empty? ? "N" : "M*"
    }.join(", ")
  end

  attr_writer :remove
  def remove
    @remove || ""
  end

  def title
    item.respond_to?(:title) ? item.title : item.bookmarkable.title
  end

  def recipients
    item.respond_to?(:recipients) ? item.recipients : ""
  end

  def item_creator_names
    item_creator_pseuds.collect(&:byline).join(', ')
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
    user.is_author_of?(self.item) || self.collection.user_is_maintainer?(user)
  end

  def approve_by_user ; self.user_approval_status = APPROVED ; end
  def reject_by_user ; self.user_approval_status = REJECTED ; end
  def approved_by_user? ; self.user_approval_status == APPROVED ; end
  def rejected_by_user? ; self.user_approval_status == REJECTED ; end

  def approve_by_collection ; self.collection_approval_status = APPROVED ; end
  def reject_by_collection ; self.collection_approval_status = REJECTED ; end
  def approved_by_collection? ; self.collection_approval_status == APPROVED ; end
  def rejected_by_collection? ; self.collection_approval_status == REJECTED ; end

  def approved? ; approved_by_user? && approved_by_collection? ; end
  def rejected? ; rejected_by_user? && rejected_by_collection? ; end

  def reject(user)
    reject_by_user if user && user.is_author_of?(item)
    reject_by_collection if user && self.collection.user_is_maintainer?(user)
  end

  def approve(user)
    if user.nil?
      # this is being run via rake task eg for importing collections
      approve_by_user
      approve_by_collection
    end
    approve_by_user if user && (user.is_author_of?(item) || (user == User.current_user && item.respond_to?(:pseuds) ? item.pseuds.empty? : item.pseud.nil?) )
    approve_by_collection if user && self.collection.user_is_maintainer?(user)
  end

  # Reveal an individual collection item
  # Can't use update_attribute because of potential validation issues
  # with closed collections
  def reveal!
    collection.collection_items.where("id = #{self.id}").update_all("unrevealed = 0")
    notify_of_reveal
  end

  def posted?
    self.item.respond_to?(:posted?) ? self.item.posted? : true
  end

  def notify_of_reveal
    unless self.unrevealed? || !self.posted?
      recipient_pseuds = Pseud.parse_bylines(self.recipients, assume_matching_login: true)[:pseuds]
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
