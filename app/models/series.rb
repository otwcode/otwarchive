class Series < ActiveRecord::Base
  has_many :serial_works, :dependent => :destroy
  has_many :works, :through => :serial_works
  has_bookmarks
  has_many :creatorships, :as => :creation
  has_many :pseuds, :through => :creatorships
	has_many :users, :through => :pseuds, :uniq => true
  
  validates_presence_of :title
  validates_length_of :title, 
    :minimum => ArchiveConfig.TITLE_MIN, 
    :too_short=> t('title_too_short', :default => "must be at least {{min}} letters long.", :min => ArchiveConfig.TITLE_MIN)

  validates_length_of :title, 
    :maximum => ArchiveConfig.TITLE_MAX, 
    :too_long=> t('title_too_long', :default => "must be less than {{max}} letters long.", :max => ArchiveConfig.TITLE_MAX)
    
  validates_length_of :summary, 
    :allow_blank => true, 
    :maximum => ArchiveConfig.SUMMARY_MAX, 
    :too_long => t('summary_too_long', :default => "must be less than {{max}} letters long.", :max => ArchiveConfig.SUMMARY_MAX)
    
  validates_length_of :notes, 
    :allow_blank => true, 
    :maximum => ArchiveConfig.NOTES_MAX, 
    :too_long => t('notes_too_long', :default => "must be less than {{max}} letters long.", :max => ArchiveConfig.NOTES_MAX)

  attr_accessor :authors
  attr_accessor :toremove
 
  def posted_works
    self.works.posted
  end
  
  # visibility aped from the work model
  def visible(current_user=User.current_user)
    if current_user.is_a?(Admin) || (current_user.is_a?(User) && current_user.is_author_of?(self))
      return self
    elsif current_user == :false || !current_user
      return self unless self.restricted || self.hidden_by_admin
    elsif (!self.hidden_by_admin && !self.posted_works.empty?)
      return self
    end
  end

  def visible?(user=User.current_user)
    self.visible(user) == self
  end
	
	# if the series includes an unrestricted work, restricted should be false
	# if the series includes no unrestricted works, restricted should be true
	def adjust_restricted
		unless self.restricted == !self.works.collect(&:restricted).include?(false)
		  self.toggle!(:restricted)
		end
	end
	
	# Change the positions of the serial works in the series
	def reorder(positions)
	  SortableList.new(self.serial_works.in_order).reorder_list(positions)
	end
  
  # return list of pseuds on this series
  def allpseuds
    works.collect(&:pseuds).flatten.compact.uniq.sort
  end
  
  # return list of users on this series
  def owners
    self.authors.collect(&:user)
  end

  # Virtual attribute for pseuds
  def author_attributes=(attributes)
    self.authors ||= []
    wanted_ids = attributes[:ids]
    wanted_ids.each { |id| self.authors << Pseud.find(id) }
    # if current user has selected different pseuds
    current_user = User.current_user
    if current_user.is_a? User
      self.toremove = current_user.pseuds - wanted_ids.collect {|id| Pseud.find(id)}
    end
    attributes[:ambiguous_pseuds].each { |id| self.authors << Pseud.find(id) } if attributes[:ambiguous_pseuds]
    if attributes[:byline]
      results = Pseud.parse_bylines(attributes[:byline])
      self.authors << results[:pseuds]
      self.invalid_pseuds = results[:invalid_pseuds]
      self.ambiguous_pseuds = results[:ambiguous_pseuds] 
    end
    self.authors.flatten!
    self.authors.uniq!
  end
  
  # returns list of fandoms on this series
  def allfandoms
    works.collect(&:fandoms).flatten.compact.uniq.sort
  end
  
  # Grabs the earliest published_at date of the visible works in the series
  def published_at
    self.works.visible.collect(&:published_at).compact.uniq.sort.first
  end
  
  def revised_at
    self.works.visible.collect(&:revised_at).compact.uniq.sort.last
  end
end