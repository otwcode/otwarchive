class InviteRequest < ActiveRecord::Base
  acts_as_list
  validates :email, :presence => true, :email_veracity => true  
  validates_uniqueness_of :email, :message => "is already part of our queue."
  before_validation :compare_with_users, :on => :create
  
  # Realign positions if they're incorrect
  def self.reset_order
    first_request = self.find(:first, :order => :position)
    unless first_request && first_request.position == 1
       requests = self.find(:all, :order => :position)
       requests.each_with_index {|request, index| request.update_attribute(:position, index + 1)}   
    end
  end
  
  def proposed_fill_date
    admin_settings = Rails.cache.fetch("admin_settings"){AdminSetting.first}
    number_of_rounds = (self.position.to_f/admin_settings.invite_from_queue_number.to_f).ceil - 1
    proposed_date = admin_settings.invite_from_queue_at.to_date + (admin_settings.invite_from_queue_frequency * number_of_rounds).days
    Date.today > proposed_date ? Date.today : proposed_date
  end
  
  #Ensure that invite request is for a new user
  def compare_with_users
    if User.find_by_email(self.email)
      errors.add(:email, "is already being used by an account holder.")
      return false
    end
  end

  # Invite a specified number of users
  def self.invite
    admin_settings = Rails.cache.fetch('admin_settings') { AdminSetting.first }

    order(:position).
      limit(admin_settings.invite_from_queue_number).
      each(&:invite_and_remove)

    InviteRequest.reset_order
  end

  # Turn a request into an invite and then remove it from the queue
  def invite_and_remove(creator = nil)
    attributes = { invitee_email: email, from_queue: true }
    invitation = if creator
                   creator.invitations.build(attributes)
                 else
                   Invitation.new(attributes)
                 end

    if invitation.save
      Rails.logger.info "#{invitation.invitee_email} was invited at #{Time.now}"
      destroy
    end
  end
end
