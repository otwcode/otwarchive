class Creatorship < ApplicationRecord
  belongs_to :pseud, inverse_of: :creatorships
  belongs_to :creation, inverse_of: :creatorships, polymorphic: true, touch: true

  scope :approved, -> { where(approved: true) }
  scope :invited, -> { where(approved: false) }
  scope :for_user, ->(user) { joins(:pseud).merge(user.pseuds) }

  before_destroy :expire_caches

  validates_presence_of :creation
  validates_uniqueness_of :pseud, scope: [:creation_type, :creation_id], on: :create

  before_validation :update_approved, on: :create

  def update_approved
    # Approve if the current user has special permissions:
    self.approved ||= (User.current_user.nil? ||
                       pseud&.user == User.current_user ||
                       pseud&.user == User.orphan_account ||
                       User.current_user.try(:is_archivist?))

    # Approve if the creation is a chapter and the pseud is already listed on
    # the work:
    self.approved ||= (creation.is_a?(Chapter) &&
                       creation.work.pseuds.include?(pseud))
  end

  validate :check_disallowed, on: :create
  def check_disallowed
    return if approved || pseud.nil?
    return if pseud&.user&.preference&.allow_cocreator

    errors.add(:base, ts("%{name} does not allow others to add them as a co-creator.",
                         name: pseud.byline))
  end

  validate :check_banned, on: :create
  def check_banned
    return unless pseud&.user&.banned || pseud&.user&.suspended

    errors.add(:base, ts("%{name} is currently banned and cannot be listed as a co-creator.",
                         name: pseud.byline))
  end

  validate :check_invalid, on: :create
  def check_invalid
    if missing?
      errors.add(:base, ts("Could not find a pseud '%{name}'.", name: byline))
    elsif ambiguous?
      errors.add(:base, ts("The pseud '%{name}' is ambiguous.", name: byline))
    end
  end

  validate :check_approved_becoming_false
  def check_approved_becoming_false
    if approved_changed?(from: true, to: false)
      errors.add(:approved, "cannot become false.")
    end
  end

  after_create :add_to_parents
  after_update :add_to_parents, if: :saved_change_to_approved?

  def add_to_parents
    return unless approved

    parents = if creation.is_a?(Work)
                creation.series.to_a
              elsif creation.is_a?(Chapter)
                [creation.work]
              else
                []
              end

    parents.each do |parent|
      parent.creatorships.approve_or_create_by(pseud: pseud)
    end
  end

  after_destroy :remove_from_children

  def remove_from_children
    children = if creation.is_a?(Work)
                 creation.chapters.to_a
               elsif creation.is_a?(Series)
                 creation.works.to_a
               else
                 []
               end

    children.each do |child|
      child.creatorships.where(pseud: pseud).destroy_all
    end
  end

  after_commit :update_indices

  # Make sure that both the creation and the pseud are enqueued to be
  # reindexed.
  def update_indices
    if creation.is_a?(Searchable)
      creation.enqueue_to_index
    end

    if pseud && creation.is_a?(Work)
      IndexQueue.enqueue(pseud, :background)
    end
  end

  attr_accessor :disable_notifications

  after_create_commit :notify_creator, unless: :disable_notifications

  # Notify the pseud of their new creatorship.
  def notify_creator
    return if (User.current_user == pseud.user ||
               User.orphan_account == pseud.user)

    if approved
      UserMailer.creatorship_notification(id).deliver
    else
      UserMailer.creatorship_invitation(id).deliver
    end
  end

  before_destroy :check_not_last

  # When deleting a creatorship, we want to make sure we're not deleting the
  # very last creatorship for that item.
  def check_not_last
    # Check that the creation hasn't been deleted:
    return if creation.nil? || creation.destroyed? ||
      creation.class.where(id: creation.id).empty? ||
      creation.creatorships.all.count > 1

    errors.add(:base, ts("Sorry, we cannot remove the last creator."))
    raise ActiveRecord::RecordInvalid, self
  end


  def self.approve_or_create_by(options)
    creatorship = find_or_initialize_by(options)
    creatorship.approved = true
    creatorship.save
  end

  attr_reader :ambiguous_pseuds

  def byline
    @byline || pseud&.byline
  end

  def byline=(byline)
    pseuds = Pseud.parse_byline(byline).to_a

    if pseuds.size == 1
      self.pseud = pseuds.first
      @byline = nil
      @ambiguous_pseuds = nil
    else
      self.pseud = nil
      @byline = byline
      @ambiguous_pseuds = pseuds
    end
  end

  def missing?
    pseud.nil? && @ambiguous_pseuds.blank?
  end

  def ambiguous?
    pseud.nil? && @ambiguous_pseuds.present?
  end

  # Change authorship of works or series from a particular pseud to the orphan account
  def self.orphan(pseuds, orphans, default=true)
    for pseud in pseuds
      for new_orphan in orphans
        unless pseud.blank? || new_orphan.blank? || !new_orphan.pseuds.include?(pseud)
          orphan_pseud = default ? User.orphan_account.default_pseud : User.orphan_account.pseuds.find_or_create_by(name: pseud.name)
          options = (new_orphan.is_a?(Series)) ? {skip_series: true} : {}
          pseud.change_ownership(new_orphan, orphan_pseud, options)
        end
      end
    end
  end

  def expire_caches
    if creation_type == 'Work' && self.pseud.present?
      CacheMaster.record(creation_id, 'pseud', self.pseud_id)
      CacheMaster.record(creation_id, 'user', self.pseud.user_id)
    end
  end

  def accept!
    transaction do
      update(approved: true)

      if creation.is_a?(Work)
        creation.chapters.each do |chapter|
          chapter.creatorships.create_or_approve_by(pseud)
        end
      end
    end
  end
end
