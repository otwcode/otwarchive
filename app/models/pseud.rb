class Pseud < ActiveRecord::Base
  belongs_to :user
  has_many_polymorphs :creations, :from => [:works, :chapters, :series], :through => :creatorships   
  has_many :comments
  acts_as_commentable
  validates_presence_of :name

  #  before_destroy :move_creations_to_default
  #TODO - add this
  #after_save :check_for_inconsistencies
  
  # For use with the work and chapter forms
  def user_name
     self.user.login
  end
  
  # Produces a byline that indicates the user's name if pseud is not unique
  def byline
    Pseud.count(:conditions => {:name => name}) > 1 ? name + " [" + user_name + "]" : name
  end
  
  # Takes a comma-separated list of bylines
  # Returns a hash containing an array of pseuds and an array of bylines that couldn't be found
  def self.parse_bylines(list)
    valid_pseuds, ambiguous_pseuds, failures = [], {}, []
    bylines = list.split ","
    for byline in bylines
      if byline.include? "["
        pseud_name, user_login = byline.split('[', 2)
        conditions = ['users.login = ? AND name = ?', user_login.strip.chop, pseud_name.strip]
      else
        conditions = {:name => byline.strip}
      end
      pseuds = Pseud.find(:all, :include => :user, :conditions => conditions)
      if pseuds.length == 1 
        valid_pseuds << pseuds.first
      elsif pseuds.length > 1 
        ambiguous_pseuds[pseuds.first.name] = pseuds  
      else
        failures << byline.strip
      end  
    end
    {:pseuds => valid_pseuds, :ambiguous_pseuds => ambiguous_pseuds, :invalid_pseuds => failures}  
  end
  
  #add a group of creations to this pseud
  def add_creations(new_creations)
    self.creations << new_creations             
  end
  
  def remove_creation(creation)
    creations.delete(creation)
  end
    
  #moves the creations of the current pseud to the default
  #for some reason, is not actually moving creations before destroying it
  def move_creations_to_default
    user.default_pseud.add_creations creations
  end
  
end
