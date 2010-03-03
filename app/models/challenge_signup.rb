class ChallengeSignup < ActiveRecord::Base
  belongs_to :pseud
  has_one :user, :through => :pseud
  belongs_to :collection
  has_one :challenge, :through => :collection
  has_many :challenge_assignments, :dependent => :destroy
  
  has_many :requests, :class_name => "Prompt", :conditions => {:offer => false}, :dependent => :destroy
  has_many :offers, :class_name => "Prompt", :conditions => {:offer => true}, :dependent => :destroy
  
  accepts_nested_attributes_for :offers, :allow_destroy => true
  accepts_nested_attributes_for :requests, :allow_destroy => true

  named_scope :by_user, lambda {|user|
    {
      :select => "DISTINCT challenge_signups.*",
      :joins => "INNER JOIN pseuds ON challenge_signups.pseud_id = pseuds.id
                        INNER JOIN users ON pseuds.user_id = users.id",
      :conditions => ['users.id = ?', user.id]
    }
  }

  named_scope :in_collection, lambda {|collection| {:conditions => ['collection_id = ?', collection.id] }}
  

  ### VALIDATION
  # the validation is based on the collection's prompt restriction settings


  def user_allowed_to_destroy?(current_user) 
    (self.pseud.user == current_user) || self.collection.user_is_maintainer?(current_user)
  end
  
  def user_allowed_to_see?(current_user)
    (self.pseud.user == current_user) || user_allowed_to_see_signups?(current_user)
  end
  
  def user_allowed_to_see_signups?(user)
    self.collection.user_is_maintainer?(user) || 
      (self.challenge.respond_to?("user_allowed_to_see_signups?") && self.challenge.user_allowed_to_see_signups?(user))
  end
    
end
