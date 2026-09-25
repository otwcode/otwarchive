# encoding=utf-8

class Chapter < ApplicationRecord
  include HtmlCleaner
  include WorkChapterCountCaching
  include CreationNotifier
  include Creatable
  include Responder

  belongs_to :work, inverse_of: :chapters
  # acts_as_list scope: 'work_id = #{work_id}'

  acts_as_commentable
  has_many :comments, as: :commentable # Handled in #delete_all_comments

  validates_length_of :title, allow_blank: true, maximum: ArchiveConfig.TITLE_MAX,
    too_long: ts("must be less than %{max} characters long.", max: ArchiveConfig.TITLE_MAX)

  validates_length_of :summary, allow_blank: true, maximum: ArchiveConfig.SUMMARY_MAX,
    too_long: ts("must be less than %{max} characters long.", max: ArchiveConfig.SUMMARY_MAX)
  validates_length_of :notes, allow_blank: true, maximum: ArchiveConfig.NOTES_MAX,
    too_long: ts("must be less than %{max} characters long.", max: ArchiveConfig.NOTES_MAX)
  validates_length_of :endnotes, allow_blank: true, maximum: ArchiveConfig.NOTES_MAX,
    too_long: ts("must be less than %{max} characters long.", max: ArchiveConfig.NOTES_MAX)


  validates_presence_of :content
  validates_length_of :content, minimum: ArchiveConfig.CONTENT_MIN,
    too_short: ts("must be at least %{min} characters long.", min: ArchiveConfig.CONTENT_MIN)

  validates_length_of :content, maximum: ArchiveConfig.CONTENT_MAX,
    too_long: ts("cannot be more than %{max} characters long.", max: ArchiveConfig.CONTENT_MAX)

  attr_accessor :wip_length_placeholder

  before_validation :inherit_creatorships
  def inherit_creatorships
    if work && creatorships.empty? && current_user_pseuds.blank?
      work.pseuds_after_saving.each do |pseud|
        creatorships.build(pseud: pseud)
      end
    end
  end

  delegate :anonymous?, to: :work

  before_save :strip_title
  before_save :set_word_count
  before_save :validate_published_at

  after_create :notify_after_creation
  after_update :notify_after_update

  scope :in_order, -> { order(:position) }
  scope :posted, -> { where(posted: true) }

  before_destroy :fix_positions_before_destroy, :invalidate_chapter_count, :delete_all_comments
  after_destroy :update_work_stats

  after_save :fix_positions
  after_save :invalidate_chapter_count, if: proc { |chapter| chapter.saved_change_to_posted? }
  after_commit :update_series_index

  def fix_positions
    return unless work&.persisted?

    chapters = work.chapters.order(:position).to_a
    return if chapters.empty?

    chapters.delete(self)
    insert_at = (self.position.to_i - 1).clamp(0, chapters.length)
    chapters.insert(insert_at, self)

    positions_changed = false

    chapters.each_with_index do |chapter, index|
      correct_position = index + 1
      if chapter.position != correct_position
        Chapter.where(id: chapter.id).update_all(position: correct_position)
        positions_changed = true
      end
    end
   
    return unless positions_changed

    # Clear ActiveRecord cache so when work.chapters is queried next, the positions are correct
    work.association(:chapters).reset
    # We're caching the chapter positions in the comment blurbs and the last
    # chapter link in the work blurbs so we need to expire the blurbs and the
    # work indexes.
    work.comments.each(&:touch)
    work.expire_caches
  end

  def fix_positions_before_destroy
    if work&.persisted? && position
      chapters = work.chapters.where(["position > ?", position])
      chapters.each { |c| c.update_attribute(:position, c.position - 1) }
    end
  end

  def delete_all_comments
    inbox_comments = InboxComment.where(feedback_comment_id: total_comments.pluck(:id))

    total_comments.in_batches.delete_all
    inbox_comments.in_batches.delete_all
  end

  def update_series_index
    return unless work&.series.present? && should_reindex_series?
    work.serial_works.each(&:update_series_index)
  end

  def should_reindex_series?
    pertinent_attributes = %w[id posted]
    destroyed? || (saved_changes.keys & pertinent_attributes).present?
  end

  def invalidate_chapter_count
    if work
      invalidate_work_chapter_count(work)
    end
  end

  def moderated_commenting_enabled?
    work && work.moderated_commenting_enabled?
  end

  # strip leading spaces from title
  def strip_title
    unless self.title.blank?
      self.title = self.title.gsub(/^\s*/, '')
    end
  end

  def chapter_header
    I18n.t("activerecord.attributes.chapters.chapter_header", position: position)
  end

  def chapter_title
    self.title.blank? ? self.chapter_header : self.title
  end

  # Header plus title, used in subscriptions
  def full_chapter_title
    str = chapter_header
    if title.present?
      str += ": #{title}"
    end
    str
  end

  def display_title
    self.position.to_s + '. ' + self.chapter_title
  end

  def abbreviated_display_title
    self.display_title.length > 50 ? (self.display_title[0..50] + "...") : self.display_title
  end

  # make em-dashes into html code
#  def clean_emdashes
#    self.content.gsub!(/\xE2\x80\"/, '&#8212;')
#  end
  # check if this chapter is the only chapter of its work
  def is_only_chapter?
    self.work.chapters.count == 1
  end

  def only_non_draft_chapter?
    self.posted? && self.work.chapters.posted.count == 1
  end

  # Virtual attribute for work wip_length
  # Chapter needed its own version for sense-checking purposes
  def wip_length
    if self.new_record? && self.work.expected_number_of_chapters == self.work.number_of_chapters
      self.work.expected_number_of_chapters += 1
    elsif self.work.expected_number_of_chapters && self.work.expected_number_of_chapters < self.work.number_of_chapters
      "?"
    else
      self.work.wip_length
    end
  end

  # Can't directly access work from a chapter virtual attribute
  # Using a placeholder variable for edits, where the value isn't saved immediately
  def wip_length=(number)
    self.wip_length_placeholder = number
  end

  # Checks the chapter published_at date isn't in the future
  def validate_published_at
    if !self.published_at
      self.published_at = Date.current
    elsif self.published_at > Date.current
      errors.add(:base, ts("Publication date can't be in the future."))
      throw :abort
    end
  end

  # Set the value of word_count to reflect the length of the text in the chapter content
  def set_word_count
    if self.new_record? || self.content_changed? || self.word_count.nil?
      counter = WordCounter.new(self.content)
      self.word_count = counter.count
    else
      self.word_count
    end
  end

  # Return the name to link comments to for this object
  def commentable_name
    self.work.title
  end

  def expire_comments_count
    super
    work&.expire_comments_count
  end

  def expire_byline_cache
    Rails.cache.delete(["byline_data", cache_key])
  end
end
