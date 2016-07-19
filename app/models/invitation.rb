# Beta invitations
# http://railscasts.com/episodes/124-beta-invitations
class Invitation < ActiveRecord::Base
  belongs_to :creator, :polymorphic => true
  belongs_to :invitee, :polymorphic => true
  belongs_to :external_author

  validate :recipient_is_not_registered, :on => :create
  def recipient_is_not_registered
    # we allow invitations to be sent to existing users if the purpose is to claim an external author
    if self.invitee_email && User.find_by_email(self.invitee_email) && !self.external_author
      errors.add :invitee_email, ts('is already being used by an account holder.')
      return false
    end
  end
  
  # ensure email is valid
  validates :invitee_email, :email_veracity => true, :allow_blank => true  

  scope :unsent, :conditions => {:invitee_email => nil, :redeemed_at => nil}
  scope :unredeemed, :conditions => 'invitee_email IS NOT NULL and redeemed_at IS NULL'
  scope :redeemed, :conditions => 'redeemed_at IS NOT NULL'

  before_validation :generate_token, :on => :create
  after_save :send_and_set_date
  after_save :adjust_user_invite_status

  #Create a certain number of invitations for all valid users
  def self.grant_all(total)
    raise unless total > 0 && total < 20
    User.valid.each do |user|
      total.times do
        user.invitations.create
      end
      UserMailer.invite_increase_notification(user.id, total).deliver
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
      UserMailer.invite_increase_notification(user.id, total).deliver
    end
    User.out_of_invites.update_all('out_of_invites = 0')
  end

  def mark_as_redeemed(user=nil)
    self.invitee = user
    self.redeemed_at = Time.now
    save
  end

  private

  def generate_token
    self.token = Digest::SHA1.hexdigest([Time.now, rand].join)
  end

  def send_and_set_date
    return unless invitee_email_changed? && !invitee_email.blank?

    if external_author
      archivist = external_author.external_creatorships
                                 .collect(&:archivist)
                                 .collect(&:login)
                                 .uniq
                                 .join(', ')

      # send invite synchronously for now
      # this should now work delayed but just to be safe
      UserMailer.invitation_to_claim(id, archivist).deliver!
    else
      # send invitations actively sent by a user synchronously to avoid delays
      UserMailer.invitation(id).deliver!
    end

    self.sent_at = Time.now
  rescue StandardError => e
    errors.add(:base, "Notification email could not be sent: #{e.message}")
  end

  #Update the user's out_of_invites status
  def adjust_user_invite_status
    if self.creator.respond_to?(:out_of_invites)
      self.creator.out_of_invites = (self.creator.invitations.unredeemed.count < 1)
      self.creator.save(:validate => false)
    end
  end

end
