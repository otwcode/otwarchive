class RelatedWork < ApplicationRecord
  belongs_to :work
  belongs_to :parent, polymorphic: true, autosave: true

  attribute :url, :string
  attribute :title, :string
  attribute :author, :string
  attribute :language_id, :integer

  scope :translations, -> { where(translation: true) }
  scope :remixes, -> { where(translation: false) }
  scope :reciprocal, -> { where(reciprocal: true) }

  scope :posted_children, -> { joins(:work).where(work: { posted: true }) }
  scope :unhidden_children, -> { joins(:work).where(work: { hidden_by_admin: false }) }
  scope :unrestricted_children, -> { joins(:work).where(work: { restricted: false }) }

  # visible child works in User.related_works
  scope :children_for_user_page, lambda {
    if User.current_user.present?
      posted_children.unhidden_children
    else
      posted_children.unhidden_children.unrestricted_children
    end
  }

  # visible parent works in User.parent_work_relationships
  scope :parents_for_user_page, lambda {
    visible_work_ids = if User.current_user.present?
                      Work.visible_to_registered_user.select(:id)
                    else
                      Work.visible_to_all.select(:id)
                    end

    where(parent_type: "Work").where(parent_id: visible_work_ids)
      .or(where(parent_type: "ExternalWork").where(parent_id: ExternalWork.visible.select(:id)))
  }

  # visible user's own works in User.related_works and User.parent_work_relationships
  def self.user_works_for_user_page(user)
    if User.current_user == user
      merge(Work.unhidden)
    elsif User.current_user.present?
      reciprocal.merge(Work.posted.unhidden.revealed.non_anon)
    else
      reciprocal.merge(Work.posted.unhidden.revealed.non_anon.unrestricted)
    end
  end

  before_validation :set_parent, if: :new_record?
  def set_parent
    return if parent

    if url.include?(ArchiveConfig.APP_HOST)
      if url.match(%r{/works/(\d+)})
        self.parent = Work.find_by(id: Regexp.last_match(1))
      else
        errors.add(:parent, :not_work)
        throw :abort # don't generate any further errors
      end
    else
      self.parent = ExternalWork.find_or_initialize_by(
        url: url,
        title: title,
        author: author,
        language_id: language_id
      )
    end
  end

  validates :parent, presence: true, on: :create

  validate :check_parent_protected, on: :create
  def check_parent_protected
    return unless parent.respond_to?(:users)
    return if parent.anonymous? || parent.unrevealed?

    parent.users.each do |user|
      errors.add(:parent, :protected, login: user.login) if user.protected_user
    end
  end

  def notify_parent_owners
    if parent.respond_to?(:pseuds)
      users = parent.pseuds.collect(&:user).uniq
      orphan_account = User.orphan_account
      users.each do |user|
        unless user == orphan_account
          I18n.with_locale(user.preference.locale_for_mails) do
            UserMailer.related_work_notification(user.id, self.id).deliver_after_commit
          end
        end
      end
    end
  end
end
