class AdminSetting < ActiveRecord::Base

  belongs_to :last_updated, :class_name => 'Admin', :foreign_key => :last_updated_by
  validates_presence_of :last_updated_by
  
  before_save :update_invite_date
  before_update :check_filter_status
  
  def self.invite_from_queue_enabled?
    self.first ? self.first.invite_from_queue_enabled? : ArchiveConfig.INVITE_FROM_QUEUE_ENABLED
  end
  def self.invite_from_queue_at
    self.first.invite_from_queue_at
  end  
  def self.invite_from_queue_number
    self.first ? self.first.invite_from_queue_number : ArchiveConfig.INVITE_FROM_QUEUE_NUMBER
  end  
  def self.invite_from_queue_frequency
    self.first ? self.first.invite_from_queue_frequency : ArchiveConfig.INVITE_FROM_QUEUE_FREQUENCY
  end  
  def self.account_creation_enabled?
    self.first ? self.first.account_creation_enabled? : ArchiveConfig.ACCOUNT_CREATION_ENABLED
  end  
  def self.days_to_purge_unactivated
    self.first ? self.first.days_to_purge_unactivated : ArchiveConfig.DAYS_TO_PURGE_UNACTIVATED
  end
  def self.suspend_filter_counts?
    self.first ? self.first.suspend_filter_counts? : false
  end
  def self.enable_test_caching?
    self.first ? self.first.enable_test_caching? : false
  end
  def self.cache_expiration
    self.first ? self.first.cache_expiration : 10
  end  
    
    
  private
  
  def check_filter_status
    if self.suspend_filter_counts_changed?
      if self.suspend_filter_counts?
        self.suspend_filter_counts_at = Time.now
      else
        FilterTagging.update_filter_counts_since(self.suspend_filter_counts_at)
      end
    end
  end
  
  def update_invite_date
    if self.invite_from_queue_frequency_changed?
      self.invite_from_queue_at = Time.now + self.invite_from_queue_frequency.days
    end
  end

end
