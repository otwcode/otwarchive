class InviteRequest < ApplicationRecord
  include ActiveModel::ForbiddenAttributesProtection
  acts_as_list
  validates :email, presence: true, email_veracity: true
  validates_uniqueness_of :email, message: "is already part of our queue.", case_sensitive: false
  before_validation :compare_with_users, on: :create
  before_validation :set_simplified_email, on: :create
  validate :simplified_email_uniqueness, on: :create

  # Realign positions if they're incorrect
  def self.reset_order
    first_request = order(:position).first
    unless first_request && first_request.position == 1
      requests = order(:position)
      requests.each_with_index {|request, index| request.update_attribute(:position, index + 1)}
    end
  end

  # Borrow the blacklist cleaner but just strip out all the periods for all domains
  def set_simplified_email
    return if email.blank?
    simplified = AdminBlacklistedEmail.canonical_email(email).split('@')
    self.simplified_email = simplified.first.delete(".").gsub(/\+.+$/, "") + "@#{simplified.last}"
  end

  # Doing this with a method so the error message makes more sense
  def simplified_email_uniqueness
    if InviteRequest.where(simplified_email: simplified_email).exists?
      errors.add(:email, "is already part of our queue.")
    end
  end

  def proposed_fill_date
    admin_settings = AdminSetting.current
    number_of_rounds = (self.position.to_f/admin_settings.invite_from_queue_number.to_f).ceil - 1
    proposed_date = admin_settings.invite_from_queue_at.to_date + (admin_settings.invite_from_queue_frequency * number_of_rounds).days
    Date.today > proposed_date ? Date.today : proposed_date
  end

  #Ensure that invite request is for a new user
  def compare_with_users
    if User.find_by(email: self.email)
      errors.add(:email, "is already being used by an account holder.")
      throw :abort
    end
  end

  #Invite a specified number of users
  def self.invite
    admin_settings = AdminSetting.current
    self.order(:position).limit(admin_settings.invite_from_queue_number).each do |request|
      request.invite_and_remove
    end
    InviteRequest.reset_order
  end

  #Turn a request into an invite and then remove it from the queue
  def invite_and_remove(creator=nil)
    invitation = creator ? creator.invitations.build(invitee_email: self.email, from_queue: true) :
                                       Invitation.new(invitee_email: self.email, from_queue: true)
    if invitation.save
      Rails.logger.info "#{invitation.invitee_email} was invited at #{Time.now}"
      self.destroy
    end
  end

end
