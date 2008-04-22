class Pseud < ActiveRecord::Base
  belongs_to :user
  has_many_polymorphs :creations, :from => [:works, :chapters], :through => :creatorships   
  has_many :comments
  acts_as_commentable
  #  before_destroy :move_creations_to_default
  #TODO - add this
  #after_save :check_for_inconsistencies
  
  #add a group of creations to this pseud
  def add_creations(new_creation)
    creations << new_creation
  end
  
  def remove_creation(creation)
    creations.delete(creation)
  end
  
  #moves the creations of the current pseud to the default
  #for some reason, is not actually moving creations before destroying it
  def move_creations_to_default
    user.default_pseud.add_creations creations
  end
  
  # Returns an array of pseuds from form parameters
  def self.get_pseuds_from_params(pseud_ids, pseud_names = nil)
    if pseud_names
      pseuds = Pseud.parse_extra_pseuds(pseud_names)
    else
      pseuds = []
    end

    for pseud_id in pseud_ids
      pseuds << Pseud.find(pseud_id)
    end
    pseuds
  end
  
  # Gets an array of pseuds from a string (ie, "user:pseud, user:pseud, user:pseud")
  # Needs more validation and a way to tell the user if we can't find one of their pseuds
  def self.parse_extra_pseuds(list)
    if list && list.class.to_s == "String" 
      bylines = list.split(',')
      pseuds = []
      for byline in bylines
        byline.strip!
        split = byline.split(':', 2)
        user_login = split.first
        pseud_name = split.last
        user = User.find_by_login(user_login)
        if user
          pseud = Pseud.find(:first, :conditions => ["user_id = (?) AND name = (?)", user.id, pseud_name])
          pseuds << pseud
        end
      end
      pseuds
    else
      []
    end
  end
  
end
