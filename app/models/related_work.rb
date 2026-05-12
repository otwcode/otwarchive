class RelatedWork < ActiveRecord::Base
  belongs_to :work
  belongs_to :parent, polymorphic: true, autosave: true

  attribute :url, :string
  attribute :title, :string
  attribute :author, :string
  attribute :language_id, :integer

  scope :translations, -> { where(translation: true) }
  scope :remixes, -> { where(translation: false) }

  scope :posted, lambda {
    joins("INNER JOIN works child_works ON child_works.id = related_works.work_id")
      .where("child_works.posted = 1")
  }

  scope :reciprocal, -> { where(reciprocal: true) }

  scope :unhidden, lambda {
    joins("INNER JOIN works child_works ON child_works.id = related_works.work_id")
      .where("child_works.hidden_by_admin = false")
  }

  def self.visible_on_user_page(user)
    if User.current_user.is_a?(Admin) || user == User.current_user
      posted.merge(Work.unhidden)
    else
      posted.reciprocal.merge(Work.revealed.non_anon.unhidden)
    end
  end

  scope :visible_works, -> { unhidden }

  scope :of_local_works, -> { where(parent_type: Work) }
  scope :of_external_works, -> { where(parent_type: ExternalWork) }

  scope :of_visible_local_works, lambda {
    of_local_works
      .joins("INNER JOIN works parent_works ON parent_works.id = related_works.parent_id")
      .where("parent_works.hidden_by_admin = false")
  }

  scope :of_visible_external_works, lambda {
    of_external_works
      .joins("INNER JOIN external_works parent_works ON parent_works.id = related_works.parent_id")
      .where("parent_works.hidden_by_admin = false")
  }

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
