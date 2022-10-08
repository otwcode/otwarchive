class AdminPost < ApplicationRecord
  self.per_page = 8 # option for WillPaginate

  acts_as_commentable
  enum :comment_permissions, {
    enable_all: 0,
    disable_anon: 1,
    disable_all: 2
  }, default: :disable_anon, suffix: :comments, validate: { message: :invalid_permissions }

  has_many :kudos, as: :commentable, inverse_of: :commentable, dependent: :destroy

  belongs_to :language
  belongs_to :translated_post, class_name: "AdminPost"
  has_many :translations, class_name: "AdminPost", foreign_key: "translated_post_id", dependent: :destroy
  has_many :admin_post_taggings
  has_many :tags, through: :admin_post_taggings, source: :admin_post_tag

  validates_presence_of :title
  validates_length_of :title,
    minimum: ArchiveConfig.TITLE_MIN,
    too_short: ts("must be at least %{min} characters long.", min: ArchiveConfig.TITLE_MIN)

  validates_length_of :title,
    maximum: ArchiveConfig.TITLE_MAX,
    too_long: ts("must be less than %{max} characters long.", max: ArchiveConfig.TITLE_MAX)

  validates_presence_of :content
  validates_length_of :content, minimum: ArchiveConfig.CONTENT_MIN,
    too_short: ts("must be at least %{min} characters long.", min: ArchiveConfig.CONTENT_MIN)

  validates_length_of :content, maximum: ArchiveConfig.CONTENT_MAX,
    too_long: ts("cannot be more than %{max} characters long.", max: ArchiveConfig.CONTENT_MAX)

  validate :translated_post_must_exist

  validate :translated_post_language_must_differ
  validate :translated_post_must_be_posted_first

  scope :non_translated, -> { where("translated_post_id IS NULL") }

  scope :for_homepage, -> { posted.order(published_at: :desc).limit(ArchiveConfig.NUMBER_OF_ITEMS_VISIBLE_ON_HOMEPAGE) }

  scope :unposted, -> { where(posted: false) }
  scope :posted, -> { where(posted: true) }

  before_validation :inherit_translated_post_attributes
  before_save :apply_tag_list
  before_save :set_published_at, if: :posted_changed?
  after_destroy :expire_cached_home_admin_posts
  after_save :expire_cached_home_admin_posts, :update_translation_attributes
  after_save :post_translations, if: :saved_change_to_posted?

  # Return the name to link comments to for this object
  def commentable_name
    self.title
  end

  def commentable_owners
    begin
        [Admin.find(self.admin_id)]
    rescue
      []
    end
  end

  def draft?
    !self.posted?
  end

  def tag_list
    @tag_list&.join(", ") || tags.map(&:name).join(", ")
  end

  def tag_list=(list)
    @tag_list = list.split(",").uniq if translated_post_id.blank?
  end
  
  def tags=(tags)
    @tag_list = nil
    super(tags)
  end
  
  def tags
    return super unless @tag_list
    
    @tag_list.collect do |name|
      AdminPostTag.fetch(name.strip, self.language_id)
    end.compact
  end

  def translated_post_must_exist
    if translated_post_id.present? && AdminPost.find_by(id: translated_post_id).nil?
      errors.add(:translated_post_id, "does not exist")
    end
  end
  
  def guest_kudos_count
    Rails.cache.fetch "admin_posts/#{id}/guest_kudos_count-v2" do
      kudos.by_guest.count
    end
  end

  def all_kudos_count
    Rails.cache.fetch "admin_posts/#{id}/kudos_count-v2" do
      kudos.count
    end
  end

  def translated_post_language_must_differ
    return if translated_post.blank?
    return unless translated_post.language == language

    errors.add(:translated_post_id, "cannot be same language as original post")
  end

  def translated_post_must_be_posted_first
    return if translated_post.blank?

    errors.add(:translated_post_id, :must_be_posted_first) if translated_post.draft? && self.posted?
  end

  ####################
  # DELAYED JOBS
  ####################

  include AsyncWithResque
  @queue = :utilities

  # Turns off comments for all posts that are older than the configured time period.
  # If the configured period is nil or less than 1 day, no action is taken.
  def self.disable_old_post_comments
    return unless ArchiveConfig.ADMIN_POST_COMMENTING_EXPIRATION_DAYS&.positive?

    where.not(comment_permissions: :disable_all)
      .where(created_at: ..ArchiveConfig.ADMIN_POST_COMMENTING_EXPIRATION_DAYS.days.ago)
      .update_all(comment_permissions: :disable_all)
  end

  private

  def expire_cached_home_admin_posts
    unless Rails.env.development?
      Rails.cache.delete("v1/home/index/home_admin_posts")
    end
  end

  def inherit_translated_post_attributes
    return if translated_post.blank?

    self.comment_permissions = translated_post.comment_permissions
    self.tags = translated_post.tags
  end
  
  def apply_tag_list
    return unless @tag_list

    self.tags = @tag_list.collect do |name|
      AdminPostTag.fetch(name.strip, self.language_id)
    end.compact
  end

  def update_translation_attributes
    return if translations.blank?

    transaction do
      translations.find_each do |post|
        post.tags = self.tags
        post.comment_permissions = self.comment_permissions
        post.save
      end
    end
  end

  def set_published_at
    self.published_at = Time.current if self.posted && !self.published_at
  end

  def post_translations
    return if translations.blank? || !self.posted

    translations.update_all(posted: true, published_at: self.published_at)
  end
end
