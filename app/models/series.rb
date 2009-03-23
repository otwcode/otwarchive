class Series < ActiveRecord::Base
  has_many :serial_works, :dependent => :destroy
  has_many :works, :through => :serial_works
  has_bookmarks
  has_many :creatorships, :as => :creation
  has_many :pseuds, :through => :creatorships
  
  validates_presence_of :title
  validates_length_of :title, 
    :minimum => ArchiveConfig.TITLE_MIN, :too_short=> "must be at least " + ArchiveConfig.TITLE_MIN.to_s + " letters long."

  validates_length_of :title, 
    :maximum => ArchiveConfig.TITLE_MAX, :too_long=> "must be less than " + ArchiveConfig.TITLE_MAX.to_s + " letters long."
    
  validates_length_of :summary, 
    :allow_blank => true, 
    :maximum => ArchiveConfig.SUMMARY_MAX, :too_long => "must be less than " + ArchiveConfig.SUMMARY_MAX.to_s + " letters long."
    
  validates_length_of :notes, 
    :allow_blank => true, 
    :maximum => ArchiveConfig.NOTES_MAX, :too_long => "must be less than " + ArchiveConfig.NOTES_MAX.to_s + " letters long."

  after_save :save_creatorships

  attr_accessor :authors
  attr_accessor :toremove
 
  def posted_works
    self.works.select{|w| w.posted}
  end
  
  # visibility aped from the work model
  def visible(current_user=User.current_user)
    if current_user == :false || !current_user || !current_user.is_a?(User)
      return self unless self.restricted || self.hidden_by_admin
    elsif (!self.hidden_by_admin && !self.posted_works.empty?) || (self.works.empty? && current_user.is_author_of?(self))
      return self
    elsif self.hidden_by_admin?
      return self if current_user.kind_of?(Admin) || current_user.is_author_of?(self)
    end
  end

  def visible?(user=User.current_user)
    self.visible(user) == self
  end
  
  # return list of pseuds on this series
  def allpseuds
    works.collect(&:pseuds).flatten.compact.uniq.sort
  end
  
  # return list of users on this series
  def owners
    self.authors.collect(&:user)
  end

  def serials=(positions)
    self.reorder_works(positions)
  end
  
  # Reorders serial_works in series based on form data
	# Similar to reorder_chapters method in work.rb
  def reorder_works(positions)
    serials = self.serial_works.find(:all, :order => 'position')
    changed = {}
    positions.collect!(&:to_i).each_with_index do |new_position, old_position|
    	if new_position != 0 && new_position <= self.serial_works.count && !changed.has_key?(new_position)
    		changed.merge!({new_position => serials[old_position]})
    	end
    end
    serials -= changed.values
    changed.sort.each {|pair| pair.first > serials.length ? serials << pair.last : serials.insert(pair.first-1, pair.last)}
    serials.each_with_index {|serial, index| serial.update_attribute(:position, index + 1)}
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
  

  # Save creatorships (add the virtual authors to the real pseuds) after the series is saved
  def save_creatorships
    if self.authors
      new = self.authors - self.pseuds
      self.pseuds << new rescue nil
    end
    if self.toremove
      self.pseuds.delete(self.toremove)
    end
  end
end
