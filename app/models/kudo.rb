class Kudo < ActiveRecord::Base
  belongs_to :pseud
  belongs_to :commentable, :polymorphic => true

  validates_uniqueness_of :pseud_id,
    :scope => [:commentable_id, :commentable_type],
    :message => ts("^You have already left kudos here. :)"),
    :if => "!pseud.nil?"

  validates_uniqueness_of :ip_address,
    :scope => [:commentable_id, :commentable_type],
    :message => ts("^You have already left kudos here. :)"),
    :if => "!ip_address.blank?"

  scope :with_pseud, where("pseud_id IS NOT NULL")
  scope :by_guest, where("pseud_id IS NULL")

  # return either the name of the kudo-leaver or "guest"
  def name
    if self.pseud
      pseud.name
    else
      "guest"
    end
  end

  def dup?
    errors.values.to_s.match /already left kudos/
  end
end
