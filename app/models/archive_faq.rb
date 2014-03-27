class ArchiveFaq < ActiveRecord::Base
  acts_as_list


  has_many :questions, :dependent => :destroy
  accepts_nested_attributes_for :questions


  attr_protected :content_sanitizer_version
  attr_accessor :notify_translations

  scope :non_translated, where('translated_faq_id IS NULL')

  # When we modify either a FAQs Category name or one of the Questions, we send an email to Translations.
  after_save :notify_translations_committee
  def notify_translations_committee
    # Check first to see if we are asked to send an email return if not
    unless !self.email_translations?
      self.questions.each do |question|
        if question.changed?
          (@changed_questions ||= []) << question
        end
      end
      # A Question could have changed, or the Title of the FAQ Category
      if @changed_questions.present? || self.title_changed?
        AdminMailer.edited_faq(self.id, User.current_user.login).deliver
      end
    end
  end

  def email_translations?
    notify_translations == "1"
  end

  def self.reorder(positions)
    SortableList.new(self.find(:all, :order => 'position ASC')).reorder_list(positions)
  end

end