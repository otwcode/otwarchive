# frozen_string_literal: true

module WorkRecipients
  extend ActiveSupport::Concern

  included do
    has_many :gifts, dependent: :destroy
    accepts_nested_attributes_for :gifts, allow_destroy: true

    attr_accessor :new_gifts

    validate :new_recipients_allow_gifts
    validate :new_recipients_have_not_blocked_gift_giver
  end

  def recipients=(recipient_names)
    new_gifts = []
    gifts = [] # rebuild the list of associated gifts using the new list of names
    # add back in the rejected gift recips; we don't let users delete rejected gifts in order to prevent regifting
    recip_names = recipient_names.split(',') + self.gifts.are_rejected.collect(&:recipient)
    recip_names.uniq.each do |name|
      name.strip!
      gift = self.gifts.for_name_or_byline(name).first
      if gift
        gifts << gift # new gifts are added after saving, not now
        new_gifts << gift unless self.posted # all gifts are new if work not posted
      else
        g = self.gifts.new(recipient: name)
        if g.valid?
          new_gifts << g # new gifts are added after saving, not now
        else
          g.errors.full_messages.each { |msg| self.errors.add(:base, msg) }
        end
      end
    end
    self.gifts = gifts
    self.new_gifts = new_gifts
  end

  def recipients(for_form = false)
    names = (for_form ? self.gifts.not_rejected : self.gifts).collect(&:recipient)
    names << self.new_gifts.collect(&:recipient) if self.new_gifts.present?
    names.flatten.uniq.join(",")
  end

  private

  def new_recipients_allow_gifts
    return if self.new_gifts.blank?

    self.new_gifts.each do |gift|
      next if gift.pseud.blank?
      next if gift.pseud&.user&.preference&.allow_gifts?
      next if challenge_bypass(gift)

      self.errors.add(:base, :blocked_gifts, byline: gift.pseud.byline)
    end
  end

  def new_recipients_have_not_blocked_gift_giver
    return if self.new_gifts.blank?

    self.new_gifts.each do |gift|
      # Already dealt with in #new_recipients_allow_gifts
      next if gift.pseud&.user&.preference && !gift.pseud.user.preference.allow_gifts?

      next if challenge_bypass(gift)

      blocked_users = gift.pseud&.user&.blocked_users || []
      next if blocked_users.empty?

      pseuds_after_saving.each do |pseud|
        next unless blocked_users.include?(pseud.user)

        if User.current_user == pseud.user
          self.errors.add(:base, :blocked_your_gifts, byline: gift.pseud.byline)
        else
          self.errors.add(:base, :blocked_gifts, byline: gift.pseud.byline)
        end
      end
    end
  end

  def save_new_gifts
    return if self.new_gifts.blank?

    self.new_gifts.each do |gift|
      next if self.gifts.for_name_or_byline(gift.recipient).present?

      # Recreate the gift once the work is saved. This ensures the work_id is
      # set properly.
      Gift.create(recipient: gift.recipient, work: self)
    end
  end

  def challenge_bypass(gift)
    self.challenge_assignments.map(&:requesting_pseud).include?(gift.pseud) ||
      self.challenge_claims
        .reject { |c| c.request_prompt.anonymous? }
        .map(&:requesting_pseud)
        .include?(gift.pseud)
  end
end
