class CollectionItem < ActiveRecord::Base

  NEUTRAL = 0
  APPROVED = 1
  REJECTED = -1

  LABEL = {}
  LABEL[NEUTRAL] = t('collection_item.neutral', :default => "Neutral")
  LABEL[APPROVED] = t('collection_item.approved', :default => "Approved")
  LABEL[REJECTED] = t('collection_item.rejected', :default => "Rejected")
  
  APPROVAL_OPTIONS = [ [LABEL[NEUTRAL], NEUTRAL],
                       [LABEL[APPROVED], APPROVED],
                       [LABEL[REJECTED], REJECTED] ]

  belongs_to :collection
  belongs_to :item, :polymorphic => :true
  belongs_to :work,  :class_name => "Work", :foreign_key => "item_id"
  belongs_to :bookmark, :class_name => "Bookmark", :foreign_key => "item_id"
  
  has_many :approved_collections, :through => :collection_items, :source => :collection,
    :conditions => ['collection_items.user_approval_status = ? AND collection_items.collection_approval_status = ?', CollectionItem::APPROVED, CollectionItem::APPROVED]
    
  validates_uniqueness_of :collection_id, :scope => [:item_id, :item_type], 
    :message => t('collection_item.not_unique', :default => "already contains this item.")
  
  validates_numericality_of :user_approval_status, :allow_blank => true, :only_integer => true
  validates_inclusion_of :user_approval_status, :in => [-1, 0, 1], :allow_blank => true,
    :message => t('collection_item.invalid_status', :default => "is not a valid approval status.")

  validates_numericality_of :collection_approval_status, :allow_blank => true, :only_integer => true
  validates_inclusion_of :collection_approval_status, :in => [-1, 0, 1], :allow_blank => true, 
    :message => t('collection_item.invalid_status', :default => "is not a valid approval status.")
  
  validate :collection_is_open, :on => :create
  def collection_is_open
    if self.new_record? && self.collection && self.collection.closed?
      errors.add_to_base t('collection_preferences.closed', :default => "Collection {{title}} is currently closed.", :title => self.collection.title) 
    end
  end
  
  named_scope :include_for_works, :include => [{:work => :pseuds}]
  named_scope :unrevealed, :conditions => {:unrevealed => true}
  named_scope :anonymous, :conditions =>  {:anonymous => true}
  
  before_save :set_anonymous_and_unrevealed
  def set_anonymous_and_unrevealed
    if self.new_record? && collection
      self.unrevealed = true if collection.unrevealed?
      self.anonymous = true if collection.anonymous?
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

  def check_gift_received(has_received)
    item_creator_pseuds.map {|pseud| 
      has_received[pseud.name] ? "Y" :
        (pseud.user.pseuds.collect(&:name).flatten & has_received.keys).empty? ? "N" : "M*"
    }.join(", ")
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
    approve_by_user if user && (user.is_author_of?(item) || (user == User.current_user && item.respond_to?(:pseuds) ? item.pseuds.empty? : item.pseud.nil?) )
    approve_by_collection if user && self.collection.user_is_maintainer?(user)
  end  
  
  def reveal!
    # if this item was previously unrevealed, reveal it now & notify the recipient if there was one
    if self.unrevealed
      self.unrevealed = false
      recipient_pseuds = Pseud.parse_bylines(self.recipients, :assume_matching_login => true)[:pseuds]
      recipient_pseuds.each do |pseud|
        unless pseud.user.preference.recipient_emails_off
          UserMailer.deliver_recipient_notification(pseud.user, self.item, self.collection)
        end
      end

      # also notify the owners of any parent/inspired-by works 
      if item_type == "Work" && !item.parent_work_relationships.empty?
        item.parent_work_relationships.each {|relationship| relationship.notify_parent_owners}
      end

      save
    end
  end
  
  def reveal_author!
    self.anonymous = false
    save
  end

end
