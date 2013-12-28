class CollectionItem < ActiveRecord::Base

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

  belongs_to :collection, :inverse_of => :collection_items
  belongs_to :item, :polymorphic => :true, :inverse_of => :collection_items
  belongs_to :work,  :class_name => "Work", :foreign_key => "item_id", :inverse_of => :collection_items
  belongs_to :bookmark, :class_name => "Bookmark", :foreign_key => "item_id"

  has_many :approved_collections, :through => :collection_items, :source => :collection,
    :conditions => ['collection_items.user_approval_status = ? AND collection_items.collection_approval_status = ?', CollectionItem::APPROVED, CollectionItem::APPROVED]

  validates_uniqueness_of :collection_id, :scope => [:item_id, :item_type],
    :message => ts("already contains this item.")

  validates_numericality_of :user_approval_status, :allow_blank => true, :only_integer => true
  validates_inclusion_of :user_approval_status, :in => [-1, 0, 1], :allow_blank => true,
    :message => ts("is not a valid approval status.")

  validates_numericality_of :collection_approval_status, :allow_blank => true, :only_integer => true
  validates_inclusion_of :collection_approval_status, :in => [-1, 0, 1], :allow_blank => true,
    :message => ts("is not a valid approval status.")

  validate :collection_is_open, :on => :create
  def collection_is_open
    if self.new_record? && self.collection && self.collection.closed? && !self.collection.user_is_maintainer?(User.current_user)
      errors.add_to_base ts("Collection %{title} is currently closed.", :title => self.collection.title)
    end
  end

  scope :include_for_works, :include => [{:work => :pseuds}]
  scope :unrevealed, :conditions => {:unrevealed => true}
  scope :anonymous, :conditions =>  {:anonymous => true}
  
  def self.for_user(user=User.current_user)
    # get ids of user's bookmarks and works
    bookmark_ids = Bookmark.joins(:pseud).where("pseuds.user_id = ?", user.id).value_of(:id)
    work_ids = Work.joins(:pseuds).where("pseuds.user_id = ?", user.id).value_of(:id)
    # now return the relation
    where("(item_id IN (?) AND item_type = 'Work') OR (item_id IN (?) AND item_type = 'Bookmark')", work_ids, bookmark_ids)
  end

  def self.approved_by_user
    where(:user_approval_status => APPROVED)
  end

  def self.rejected_by_user
    where(:user_approval_status => REJECTED)
  end

  def self.unreviewed_by_user
    where(:user_approval_status => NEUTRAL)
  end
  
  def self.approved_by_collection
    where(:collection_approval_status => APPROVED)
  end

  def self.rejected_by_collection
    where(:collection_approval_status => REJECTED)
  end
  
  def self.unreviewed_by_collection
    where(:collection_approval_status => NEUTRAL)    
  end

  before_save :set_anonymous_and_unrevealed
  def set_anonymous_and_unrevealed
    if self.new_record? && collection
      self.unrevealed = true if collection.unrevealed?
      self.anonymous = true if collection.anonymous?
    end
  end
  
  after_save :update_work
  # after_destroy :update_work: NOTE: after_destroy DOES NOT get invoked when an item is removed from a collection because
  #  this is a has-many-through relationship!!!
  # The case of removing a work from a collection has to be handled via after_add and after_remove callbacks on the work 
  # itself -- see collectible.rb
  
  # Set associated works to anonymous or unrevealed as appropriate
  # Check for chapters to avoid work association creation order shenanigans
  def update_work
    return unless item_type == 'Work' && work.present? && work.chapters.present? && !work.new_record?
    # Check if this is new - can't use new_record? with after_save
    if self.id_changed?
      work.set_anon_unrevealed!
    else
      work.update_anon_unrevealed!
    end
  end

  # Poke the item if it's just been approved or unapproved so it gets picked up by the search index
  after_update :update_item_for_status_change
  def update_item_for_status_change
    if user_approval_status_changed? || collection_approval_status_changed?
      item.save
    end
  end

  after_create :notify_of_association
  # TODO: make this work for bookmarks instead of skipping them
  def notify_of_association
    self.work.present? ? creation_id = self.work.id : creation_id = self.item_id
    if self.collection.collection_preference.email_notify && !self.collection.email.blank?
      CollectionMailer.item_added_notification(creation_id, self.collection.id, self.item_type).deliver
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
      # adding or is a member of the collection, go ahead and approve by user
      if !approved_by_user?
        case item_type
        when "Work"
          users = item.users || [User.current_user] # if the work has no users, it is also new and being created by the current user
        when "Bookmark"
          users = [item.user] || [User.current_user]
        end

        users.each do |user|
          if user.preference.automatically_approve_collections || (collection && collection.user_is_posting_participant?(user))
            approve_by_user
            break
          end
        end
      end
    end
  end
  
  after_update :notify_of_status_change
  def notify_of_status_change
    if unrevealed_changed?
      # making sure that creation_observer.rb has not already notified the user
      if !work.new_recipients.blank?
        notify_of_reveal
      end
    end
    if anonymous_changed?
      notify_of_author_reveal
    end
  end

  def check_gift_received(has_received)
    item_creator_pseuds.map {|pseud|
      has_received[pseud.name] ? "Y" :
        (pseud.user.pseuds.collect(&:name).flatten & has_received.keys).empty? ? "N" : "M*"
    }.join(", ")
  end

  def remove=(value)
    if value == "1"
      self.destroy
    end
  end

  def remove
    ""
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
    collection.collection_items.update_all("unrevealed = 0", "id = #{self.id}")
    notify_of_reveal
  end

  def posted?
    self.item.respond_to?(:posted?) ? self.item.posted? : true
  end

  def notify_of_reveal
    unless self.unrevealed? || !self.posted?
      recipient_pseuds = Pseud.parse_bylines(self.recipients, :assume_matching_login => true)[:pseuds]
      recipient_pseuds.each do |pseud|
        unless pseud.user.preference.recipient_emails_off
          UserMailer.recipient_notification(pseud.user.id, self.item.id, self.collection.id).deliver
        end
      end

      # also notify prompters of responses to their prompt
      if item_type == "Work" && !item.challenge_claims.blank?
        UserMailer.prompter_notification(self.item.id, self.collection.id).deliver
      end

      # also notify the owners of any parent/inspired-by works
      if item_type == "Work" && !item.parent_work_relationships.empty?
        item.parent_work_relationships.each do |relationship|
          relationship.notify_parent_owners
        end
      end
    end
  end

  # When the authors of anonymous works are revealed, notify users
  # subscribed to those authors
  def notify_of_author_reveal
    unless self.anonymous? || !self.posted?
      if item_type == "Work"
        subs = Subscription.where(["subscribable_type = 'User' AND subscribable_id IN (?)",
                                  item.pseuds.map{|p| p.user_id}]).
                            group(:user_id)
        subs.each do |subscription|
          RedisMailQueue.queue_subscription(subscription, item)
        end
      end      
    end
  end

end
