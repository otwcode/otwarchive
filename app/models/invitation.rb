# Beta invitations
# http://railscasts.com/episodes/124-beta-invitations
class Invitation < ActiveRecord::Base
  belongs_to :creator, :polymorphic => true
  belongs_to :invitee, :polymorphic => true

  validate :recipient_is_not_registered, :on => :create
  
  named_scope :unused, :conditions => {:redeemed_at => nil}

  before_create :generate_token

  #Create a certain number of invitations for all valid users
  def self.grant_all(total)
    raise unless total > 0 && total < 20
    User.valid.each do |user|
      total.times do 
        user.invitations.create
      end
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
    end
    User.out_of_invites.update_all('out_of_invites = 0')
  end
  
  private
  
  def recipient_is_not_registered
    if self.invitee_email && User.find_by_email(self.invitee_email)
      errors.add :invitee_email, t('already_registered', :default => 'is already registered') 
      return false
    end
  end

  def generate_token
    self.token = Digest::SHA1.hexdigest([Time.now, rand].join)
  end
  
end
