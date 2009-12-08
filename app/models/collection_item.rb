class CollectionItem < ActiveRecord::Base

  APPROVAL_OPTIONS = [ [t('collection_item.neutral', :default => "Neutral"), Collection::STATUS_NEUTRAL],
                         [t('collection_item.approved', :default => "Approved"), Collection::STATUS_APPROVED],
                         [t('collection_item.rejected', :default => "Rejected"), Collection::STATUS_REJECTED] ]

  belongs_to :collection
  belongs_to :item, :polymorphic => :true
  
  validates_uniqueness_of :collection_id, :scope => [:item_id, :item_type], 
    :message => t('collection_item.not_unique', :default => "That item appears to already be in that collection.")
  
  validates_numericality_of :user_approval_status, :allow_blank => true, :only_integer => true
  validates_inclusion_of :user_approval_status, :in => [-1, 0, 1], :allow_blank => true,
    :message => t('collection_item.invalid_status', :default => "That is not a valid approval status.")

  validates_numericality_of :collection_approval_status, :allow_blank => true, :only_integer => true
  validates_inclusion_of :collection_approval_status, :in => [-1, 0, 1], :allow_blank => true, 
    :message => t('collection_item.invalid_status', :default => "That is not a valid approval status.")
  
  def approved_by_user? 
    self.user_approval_status == Collection::STATUS_APPROVED 
  end

  def rejected_by_user? 
    self.user_approval_status == Collection::STATUS_REJECTED
  end
  
  def approved_by_collection? 
    self.collection_approval_status == Collection::STATUS_APPROVED 
  end
  
  def rejected_by_collection? 
    self.collection_approval_status == Collection::STATUS_REJECTED 
  end 

  def reject!(user)
    self.user_approval_status = Collection::STATUS_REJECTED if item.users.include?(user)
    self.collection_approval_status = Collection::STATUS_APPROVED unless (self.collection.maintainers & user.pseuds).empty?
    save
  end

  def approve!(user)
    self.user_approval_status = Collection::STATUS_APPROVED if item.users.include?(user)
    self.collection_approval_status = Collection::STATUS_APPROVED unless (self.collection.maintainers & user.pseuds).empty?
    save
  end

end
