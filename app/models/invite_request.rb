class InviteRequest < ActiveRecord::Base
  acts_as_list
  validates_presence_of :email
  validates_uniqueness_of :email
  validates_email_veracity_of :email
  
  before_validation :compare_with_users
  
  #Ensure that invite request is for a new user
  def compare_with_users
    if User.find_by_email(self.email)
      errors.add(:email, "is already in our system.")
      return false
    end
  end

end
