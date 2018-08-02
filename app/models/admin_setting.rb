class AdminSetting < ApplicationRecord
  include ActiveModel::ForbiddenAttributesProtection

  belongs_to :last_updated, class_name: 'Admin', foreign_key: :last_updated_by
  validates_presence_of :last_updated_by
  validates :invite_from_queue_number, numericality: { greater_than_or_equal_to: 1,
    allow_nil: false, message: "must be greater than 0. To <strong>disable</strong> invites, uncheck the appropriate setting." }

  before_save :update_invite_date
  before_update :check_filter_status
  after_save :expire_cached_settings

  belongs_to :default_skin, class_name: 'Skin'

  DEFAULT_SETTINGS = {
    invite_from_queue_enabled?: ArchiveConfig.INVITE_FROM_QUEUE_ENABLED,
    request_invite_enabled?: false,
    invite_from_queue_at: nil,
    invite_from_queue_number: ArchiveConfig.INVITE_FROM_QUEUE_NUMBER,
    invite_from_queue_frequency: ArchiveConfig.INVITE_FROM_QUEUE_FREQUENCY,
    account_creation_enabled?: ArchiveConfig.ACCOUNT_CREATION_ENABLED,
    days_to_purge_unactivated: ArchiveConfig.DAYS_TO_PURGE_UNACTIVATED,
    suspend_filter_counts?: false,
    disable_filtering?: false,
    enable_test_caching?: false,
    cache_expiration: 10,
    tag_wrangling_off?: false,
    downloads_enabled?: true,
    stats_updated_at: nil
  }.freeze

  def self.current
    Rails.cache.fetch("admin_settings") { AdminSetting.first } || OpenStruct.new(DEFAULT_SETTINGS)
  end

  class << self
    delegate *DEFAULT_SETTINGS.keys, :to => :current
  end

  def self.default_skin
    settings = current
    if settings.default_skin_id.present?
      Rails.cache.fetch("admin_default_skin") { settings.default_skin }
    else
      Skin.default
    end
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
