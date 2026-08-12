class RelatedWork < ActiveRecord::Base
  belongs_to :work
  belongs_to :parent, polymorphic: true, autosave: true

  attribute :url, :string
  attribute :title, :string
  attribute :author, :string
  attribute :language_id, :integer

  scope :posted, -> {
    joins("INNER JOIN `works` `child_works` ON `child_works`.`id` = `related_works`.`work_id`").
    where("child_works.posted = 1")
  }
  scope :translations, -> { where(translation: true) }
  scope :remixes, -> { where(translation: false) }
  scope :reciprocal, -> { where(reciprocal: true) }

  scope :posted_children, -> { joins(:work).where(work: { posted: true }) }
  scope :unhidden_children, -> { joins(:work).where(work: { hidden_by_admin: false }) }
  scope :unrestricted_children, -> { joins(:work).where(work: { restricted: false }) }

  scope :join_parents, lambda {
    joins("LEFT JOIN works parent_works ON (related_works.parent_type = 'Work' AND parent_works.id = related_works.parent_id)")
      .joins("LEFT JOIN external_works parent_external_works ON (related_works.parent_type = 'ExternalWork' AND parent_external_works.id = related_works.parent_id)")
  }

  scope :posted_or_deleted_parents, lambda {
    join_parents.where("parent_works.posted = true OR parent_works.id IS NULL")
  }

  scope :unhidden_or_deleted_parents, lambda {
    join_parents.where("parent_works.hidden_by_admin = false OR parent_external_works.hidden_by_admin = false OR (parent_works.id IS NULL AND parent_external_works.id IS NULL)")
  }

  def self.children_for_work_page(current_user)
    if current_user.is_a?(Admin)
      reciprocal.posted_children
    else
      reciprocal.posted_children.unhidden_children
    end
  end

  def self.parents_for_work_page(current_user)
    if current_user.is_a?(Admin)
      posted_or_deleted_parents
    else
      posted_or_deleted_parents.unhidden_or_deleted_parents
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
