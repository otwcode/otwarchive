class Pseud < ActiveRecord::Base
  belongs_to :user
  has_many_polymorphs :creations, :from => [:works, :chapters], :through => :creatorships   
  has_many :comments
  acts_as_commentable
  #  before_destroy :move_creations_to_default
  #TODO - add this
  #after_save :check_for_inconsistencies
  
  #add a group of creations to this pseud
   def add_creations (other_creations)
      creations << other_creations
    end
  def remove_creation(creation)
    creations.delete(creation)
  end
    #moves the creations of the current pseud to the default
    #for some reason, is not actually moving creations before destroying it
    def move_creations_to_default
        User.find(user_id).default_pseud.add_creations creations
    end
end
