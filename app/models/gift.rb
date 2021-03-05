class Gift < ApplicationRecord
  NAME_LENGTH_MAX = 100

  belongs_to :work, touch: true
  belongs_to :pseud
  has_one :user, through: :pseud

  validates_length_of :recipient_name,
    maximum: NAME_LENGTH_MAX,
    too_long: ts("must be less than %{max} characters long.", max: NAME_LENGTH_MAX),
    allow_blank: true

  validates_format_of :recipient_name,
    message: ts("must contain at least one letter or number."),
    with: /[a-zA-Z0-9]/,
    allow_blank: true

  validate :has_name_or_pseud
  def has_name_or_pseud
    unless self.pseud || !self.recipient_name.blank?
      errors.add(:base, ts("A gift must have a recipient specified."))
    end
  end

  validates_uniqueness_of :pseud_id,
    scope: :work_id,
    message: ts("You can't give a gift to the same person twice.")

  # Don't allow giving the same gift to the same user more than once
  validate :has_not_given_to_user
  def has_not_given_to_user
    if self.pseud && self.work
      other_pseuds = Gift.where(work_id: self.work_id).pluck(:pseud_id) - [self.pseud_id]
      if Pseud.where(id: other_pseuds, user_id: self.pseud.user_id).exists?
        errors.add(:base, ts("You seem to already have given this work to that user."))
      end
    end
  end

  validate :user_allows_gifts, on: :update
  # If the recipient is a protected user, it should not be possible to give them
  # a gift work unless it fulfills a gift exchange assignment or non-anonymous
  # prompt meme claim for the recipient.
  # We only run this on update because the necessary challenge_assignments and
  # challenge_claims information isn't available when we first create a work
  # (and the gifts for it).
  def user_allows_gifts
    return unless self.pseud&.user&.is_protected_user?
    return if self.work.challenge_assignments.map(&:requesting_pseud).include?(self.pseud)
    return if self.work.challenge_claims.reject { |c| c.request_prompt.anonymous? }.map(&:requesting_pseud).include?(self.pseud)

    errors.add(:base, ts("You can't give a gift to #{self.pseud.name}."))
  end

  scope :for_pseud, lambda {|pseud| where("pseud_id = ?", pseud.id)}

  scope :for_user, lambda {|user| where("pseud_id IN (?)", user.pseuds.collect(&:id).flatten)}

  scope :for_recipient_name, lambda {|name| where("recipient_name = ?", name)}

  scope :for_name_or_byline, lambda {|name| where("recipient_name = ? OR pseud_id = ?",
                                                  name,
                                                  Pseud.parse_byline(name, assume_matching_login: true).first)}

  scope :in_collection, lambda {|collection|
    select("DISTINCT gifts.*").
    joins({work: :collection_items}).
    where("collection_items.collection_id = ?", collection.id)
  }

  scope :name_only, -> { select(:recipient_name) }

  scope :include_pseuds, -> { includes(work: [:pseuds]) }

  scope :not_rejected, -> { where(rejected: false) }

  scope :are_rejected, -> { where(rejected: true) }

  def recipient=(new_recipient_name)
    self.pseud = Pseud.parse_byline(new_recipient_name, assume_matching_login: true).first
    self.recipient_name = pseud ? nil : new_recipient_name
  end

  def recipient
    pseud ? pseud.byline : recipient_name
  end

end
