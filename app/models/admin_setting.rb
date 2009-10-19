class AdminSetting < ActiveRecord::Base

  belongs_to :last_updated, :class_name => 'Admin', :foreign_key => :last_updated_by
  validates_presence_of :last_updated_by
  
  def self.invite_from_queue_enabled?
    self.first.andand.invite_from_queue_enabled? || ArchiveConfig.INVITE_FROM_QUEUE_ENABLED
  end
  
  def self.invite_from_queue_number
    self.first.andand.invite_from_queue_number || ArchiveConfig.INVITE_FROM_QUEUE_NUMBER
  end
  
  def self.invite_from_queue_frequency
    self.first.andand.invite_from_queue_frequency || ArchiveConfig.INVITE_FROM_QUEUE_FREQUENCY
  end
  
  def self.account_creation_enabled?
    self.first.andand.account_creation_enabled? || ArchiveConfig.ACCOUNT_CREATION_ENABLED
  end
  
  def self.days_to_purge_unactivated
    self.first.andand.days_to_purge_unactivated || ArchiveConfig.DAYS_TO_PURGE_UNACTIVATED
  end

end
