class Gift < ApplicationRecord
  NAME_LENGTH_MAX = 100

  belongs_to :work, touch: true
  belongs_to :pseud
  has_one :user, through: :pseud

  validates :recipient_name,
            length: { maximum: NAME_LENGTH_MAX, allow_blank: true },
            format: { with: /[a-zA-Z0-9]/, allow_blank: true }

  validate :has_name_or_pseud
  def has_name_or_pseud
    unless self.pseud || !self.recipient_name.blank?
      errors.add(:base, :no_recipient)
    end
  end

  validates :pseud_id, uniqueness: { scope: :work_id }

  # Don't allow giving the same gift to the same user more than once
  validate :has_not_given_to_user
  def has_not_given_to_user
    if self.pseud && self.work
      other_pseuds = Gift.where(work_id: self.work_id).pluck(:pseud_id) - [self.pseud_id]
      if Pseud.where(id: other_pseuds, user_id: self.pseud.user_id).exists?
        errors.add(:base, :already_gifted)
      end
    end
  end

  scope :for_pseud, lambda {|pseud| where("pseud_id = ?", pseud.id)}

  scope :for_user, lambda {|user| where("pseud_id IN (?)", user.pseuds.collect(&:id).flatten)}

  scope :for_recipient_name, lambda {|name| where("recipient_name = ?", name)}

  scope :for_name_or_byline, lambda { |name|
    where("recipient_name = ? OR pseud_id = ?",
          name,
          Pseud.parse_byline(name))
  }

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
    self.pseud = Pseud.parse_byline(new_recipient_name)
    self.recipient_name = pseud ? nil : new_recipient_name
  end

  def recipient
    pseud ? pseud.byline : recipient_name
  end

end
