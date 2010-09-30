class InviteRequest < ActiveRecord::Base
  acts_as_list
  validates_presence_of :email
  validates_uniqueness_of :email, :message => "is already part of our queue."
  validates :email
, :email_veracity => true  
  before_validation_on_create :compare_with_users
  
  # Realign positions if they're incorrect
  def self.reset_order
    first_request = self.find(:first, :order => :position)
    unless first_request && first_request.position == 1
       requests = self.find(:all, :order => :position)
       requests.each_with_index {|request, index| request.update_attribute(:position, index + 1)}   
    end
  end
  
  def proposed_fill_date
    number_of_rounds = (self.position.to_f/AdminSetting.invite_from_queue_number.to_f).ceil - 1
    proposed_date = AdminSetting.invite_from_queue_at.to_date + (AdminSetting.invite_from_queue_frequency * number_of_rounds).days
    Date.today > proposed_date ? Date.today : proposed_date
  end
  
  #Ensure that invite request is for a new user
  def compare_with_users
    if User.find_by_email(self.email)
      errors.add(:email, "is already being used by an account holder.")
      return false
    end
  end

  #Invite a specified number of users  
  def self.invite
    self.find(:all, :order => :position, :limit => AdminSetting.invite_from_queue_number).each do |request|
      request.invite_and_remove
    end
    InviteRequest.reset_order
  end
  
  #Turn a request into an invite and then remove it from the queue
  def invite_and_remove(creator=nil)
    invitation = creator ? creator.invitations.build(:invitee_email => self.email, :from_queue => true) : 
                                       Invitation.new(:invitee_email => self.email, :from_queue => true)
    if invitation.save
      puts "#{invitation.invitee_email} was invited at #{Time.now}"
      self.destroy
    end  
  end
  
end
