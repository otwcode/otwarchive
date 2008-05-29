class Pseud < ActiveRecord::Base
  belongs_to :user
  has_many_polymorphs :creations, :from => [:works, :chapters], :through => :creatorships   
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
  
  # Returns a hash of valid, ambiguous and invalid pseuds from a comma-separated list
  def self.get_coauthor_hash(list)
    pseud_names = list.split ","
    valid_pseuds = []
    ambiguous_pseuds = {}
    invalid_pseuds = []
    for name in pseud_names
      name.strip!
      result = Pseud.find(:all, :conditions => {:name => name}, :include => :user)
      if result.nil? || result.empty?
        invalid_pseuds << name
      elsif result.length > 1
        ambiguous_pseuds[name] = result
      else
        valid_pseuds << result.first
      end
    end
    {:pseuds => valid_pseuds, :ambiguous_pseuds => ambiguous_pseuds, :invalid_pseuds => invalid_pseuds}
  end
  
end
