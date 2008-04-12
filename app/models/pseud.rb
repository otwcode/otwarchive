class Pseud < ActiveRecord::Base
  belongs_to :user
  has_many_polymorphs :creations, :from => [:works, :chapters], :through => :creatorships
  before_destroy :move_creations_to_default
  #TODO - add this
  #after_save :check_for_inconsistencies
  
  #add a group of creations to this pseud
   def add_creations (other_creations)
    for creation in other_creations
      #creation.update_attribute(:pseud_id, id)
      creations << creation
    end
  end
  
    #moves the creations of the current pseud to the default
    #for some reason, is not actually moving creations before destroying it
    def move_creations_to_default
        User.find(user_id).active_pseud.add_creations creations
    end
end
