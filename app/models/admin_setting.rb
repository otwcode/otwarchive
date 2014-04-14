class AdminSetting < ActiveRecord::Base

  belongs_to :last_updated, :class_name => 'Admin', :foreign_key => :last_updated_by
  validates_presence_of :last_updated_by
  validates :invite_from_queue_number, :numericality => { greater_than_or_equal_to: 1,
    :allow_nil => false, :message => "must be greater than 0. To <strong>disable</strong> invites, uncheck the appropriate setting." }

  before_save :update_invite_date
  before_update :check_filter_status
  after_save :expire_cached_settings
  
  attr_protected :banner_text_sanitizer_version
  
  belongs_to :default_skin, :class_name => 'Skin'

  def self.invite_from_queue_enabled?
    self.first ? self.first.invite_from_queue_enabled? : ArchiveConfig.INVITE_FROM_QUEUE_ENABLED
  end
  def self.request_invite_enabled?
    self.first ? self.first.request_invite_enabled? : false
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
  def self.disable_filtering?
    self.first ? self.first.disable_filtering? : false
  end
  def self.enable_test_caching?
    self.first ? self.first.enable_test_caching? : false
  end
  def self.cache_expiration
    self.first ? self.first.cache_expiration : 10
  end
  def self.tag_wrangling_off?
    self.first ? self.first.tag_wrangling_off? : false
  end
  def self.guest_downloading_off?
    self.first ? self.first.guest_downloading_off? : false
  end
  def self.default_skin
    self.first ? (self.first.default_skin_id ? self.first.default_skin : Skin.default) : Skin.default
  end
  def self.stats_updated_at
    self.first ? self.first.stats_updated_at : nil
  end

  # run once a day from cron
  def self.check_queue
    if self.invite_from_queue_enabled? && InviteRequest.count > 0
      if Date.today >= self.invite_from_queue_at.to_date
        new_date = Time.now + self.invite_from_queue_frequency.days
        self.first.update_attribute(:invite_from_queue_at, new_date)
        InviteRequest.invite
      end
    end
  end
  
  @queue = :admin
  # This will be called by a worker when a job needs to be processed
  def self.perform(method, *args)
    self.send(method, *args)
  end
  
  # update admin banner setting for all users when banner notice is changed
  def self.banner_on
    Preference.update_all("banner_seen = false")
  end
    
  def self.set_stats_updated_at(time)
    if self.first 
      self.first.stats_updated_at = time
      self.first.save
    end
  end
  
  private
  
  def expire_cached_settings
    unless Rails.env.development?
      Rails.cache.delete("admin_settings")
      Rails.cache.delete("banner_text")
    end
  end

  def check_filter_status
    if self.suspend_filter_counts_changed?
      if self.suspend_filter_counts?
        self.suspend_filter_counts_at = Time.now
      else
        #FilterTagging.update_filter_counts_since(self.suspend_filter_counts_at)
      end
    end
  end

  def update_invite_date
    if self.invite_from_queue_frequency_changed?
      self.invite_from_queue_at = Time.now + self.invite_from_queue_frequency.days
    end
  end

end
