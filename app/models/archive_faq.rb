class ArchiveFaq < ApplicationRecord
  include ActiveModel::ForbiddenAttributesProtection

  acts_as_list
  translates :title

  has_many :questions, -> { order(:position) }, dependent: :destroy
  accepts_nested_attributes_for :questions, allow_destroy: true

  validates :slug, presence: true, uniqueness: true

  attr_accessor :notify_translations

  belongs_to :language

  before_validation :set_slug
  def set_slug
    if I18n.locale == :en
      self.slug = self.title.parameterize
    end
  end

  # When we modify either a FAQs Category name or one of the Questions,
  # we send an email to Translations.
  before_save :notify_translations_committee
  def notify_translations_committee
    # Check first to see if we are asked to send an email return if not
    unless !self.email_translations?
      self.questions.each do |question|
        if question.changed?
          (@changed_questions ||= []) << question
        end
      end
      # A Question or the Title of the FAQ Category could have changed
      if @changed_questions.present? || self.title_changed?
        AdminMailer.edited_faq(self.id, User.current_user.login).deliver
      end
    end
  end

  # Change the positions of the questions in the archive_faq
  def reorder(positions)
    SortableList.new(self.questions.in_order).reorder_list(positions)
  end

  def to_param
    slug_was
  end

  def email_translations?
    notify_translations == "1"
  end

  def self.reorder(positions)
    SortableList.new(self.order('position ASC')).reorder_list(positions)
  end

end
