class Pseud < ActiveRecord::Base
  belongs_to :user
  has_many_polymorphs :creations, :from => [:works, :chapters], :through => :creatorships
  before_destroy :move_creations_to_default
  
  #add a group of creations to this pseud
   def add_creations (creations)
    for creation in creations
      creation.pseud_id = @id
      @creations << creation
    end
  end
  
  private
    #moves the creations of the current pseud to the defaults
    def move_creations_to_default
      User.find(@user_id).active_pseud.add_creations @creations
    end
end
