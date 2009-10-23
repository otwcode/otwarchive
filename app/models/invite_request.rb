class InviteRequest < ActiveRecord::Base
  acts_as_list
  validates_presence_of :email
  validates_uniqueness_of :email
  validates_email_veracity_of :email
  
  before_validation :compare_with_users
  
  def proposed_fill_date
    number_of_rounds = (self.position.to_f/AdminSetting.invite_from_queue_number.to_f).ceil - 1
    AdminSetting.invite_from_queue_at + (AdminSetting.invite_from_queue_frequency * number_of_rounds).days
  end
  
  #Ensure that invite request is for a new user
  def compare_with_users
    if User.find_by_email(self.email)
      errors.add(:email, "is already in our system.")
      return false
    end
  end

  #Invite a specified number of users  
  def self.invite
    self.find(:all, :order => :position, :limit => AdminSetting.invite_from_queue_number).each do |request|
      request.invite_and_remove
    end
  end
  
  #Turn a request into an invite and then remove it from the queue
  def invite_and_remove(creator=nil)
    invitation = creator ? creator.invitations.build(:invitee_email => self.email, :from_queue => true) : 
                                       Invitation.new(:invitee_email => self.email, :from_queue => true)
    if invitation.save
      self.destroy
    end  
  end
  
end
