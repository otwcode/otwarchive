# Beta invitations
# http://railscasts.com/episodes/124-beta-invitations
class Invitation < ActiveRecord::Base
  belongs_to :creator, :polymorphic => true
  belongs_to :invitee, :polymorphic => true

  validate_on_create :recipient_is_not_registered
  
  named_scope :unsent, :conditions => {:invitee_email => nil}
  named_scope :unredeemed, :conditions => 'invitee_email IS NOT NULL and redeemed_at IS NULL'
  named_scope :redeemed, :conditions => 'redeemed_at IS NOT NULL'

  before_validation_on_create :generate_token
  before_save :send_and_set_date
  after_save :adjust_user_invite_status

  #Create a certain number of invitations for all valid users
  def self.grant_all(total)
    raise unless total > 0 && total < 20
    User.valid.each do |user|
      total.times do 
        user.invitations.create
      end
      UserMailer.deliver_invite_increase_notification(user, total)
    end
    User.out_of_invites.update_all('out_of_invites = 0')
  end
  
  #Create a certain number of invitations for all users who are out of them
  def self.grant_empty(total)
    raise unless total > 0 && total < 20
    User.valid.out_of_invites.each do |user|
      total.times do 
        user.invitations.create
      end
      UserMailer.deliver_invite_increase_notification(user, total)
    end
    User.out_of_invites.update_all('out_of_invites = 0')
  end
  
  private
  
  def recipient_is_not_registered
    if self.invitee_email && User.find_by_email(self.invitee_email)
      errors.add :invitee_email, t('already_registered', :default => 'is already being used by an account holder.') 
      return false
    end
  end

  def generate_token
    self.token = Digest::SHA1.hexdigest([Time.now, rand].join)
  end
  
  def send_and_set_date
    if self.invitee_email_changed? && !self.invitee_email.blank?
      begin
        UserMailer.deliver_invitation(self)
        self.sent_at = Time.now
      rescue
        errors.add_to_base("Notification email could not be sent.")
      end
    end
  end
  
  #Update the user's out_of_invites status
  def adjust_user_invite_status
    if self.creator.respond_to?(:out_of_invites)
      self.creator.out_of_invites = (self.creator.invitations.unredeemed.count < 1)
      self.creator.save(false)
    end  
  end
  
end
