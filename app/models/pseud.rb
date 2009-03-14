class Pseud < ActiveRecord::Base

  NAME_LENGTH_MIN = 1
  NAME_LENGTH_MAX = 40

  
  belongs_to :user
  has_many :creatorships
  has_many :works, :through => :creatorships, :source => :creation, :source_type => 'Work'
  has_many :chapters, :through => :creatorships, :source => :creation, :source_type => 'Chapter'
  has_many :series, :through => :creatorships, :source => :creation, :source_type => 'Series'
  validates_presence_of :name
  validates_length_of :name, :within => NAME_LENGTH_MIN..NAME_LENGTH_MAX, :too_short => "That name is too short (minimum is %d characters)",
        :too_long => "That name is too long (maximum is %d characters)"
 validates_format_of :name, :message => 'Pseuds can contain letters, numbers, spaces, underscores, and dashes.',
    :with => /\A[\w -]*\Z/    
  validates_format_of :name, :message => 'Pseuds must contain at least one letter or number.',
    :with => /[a-zA-Z0-9]/
    
  
  TAGGING_JOIN = "INNER JOIN taggings on tags.id = taggings.tagger_id
                  INNER JOIN works ON (works.id = taggings.taggable_id AND taggings.taggable_type = 'Work')"

  OWNERSHIP_JOIN = "INNER JOIN creatorships ON pseuds.id = creatorships.pseud_id
                    INNER JOIN works ON (creatorships.creation_id = works.id AND creatorships.creation_type = 'Work')"

  named_scope :on_works, lambda {|owned_works|
    {
      :select => "DISTINCT pseuds.*",
      :joins => OWNERSHIP_JOIN,
      :conditions => ['works.id in (?)', owned_works.collect(&:id)]
    }
  }
  
  named_scope :on_work_ids, lambda {|owned_work_ids|
    {
      :select => "DISTINCT pseuds.*",
      :joins => OWNERSHIP_JOIN,
      :conditions => ['works.id in (?)', owned_work_ids]
    }
  }
  
  named_scope :for_user, lambda {|user|
    { :conditions => ['pseuds.user_id = ?', user.id] }
  }
  
  named_scope :with_names, lambda {|pseud_names|
    {:conditions => ['pseuds.name in (?)', pseud_names]}
  }

  named_scope :alphabetical, :order => :name

  # Enigel Dec 12 08: added sort method
  # sorting by pseud name or by login name in case of equality
  def <=>(other)
    (self.name.downcase <=> other.name.downcase) == 0 ? (self.user_name.downcase <=> other.user_name.downcase) : (self.name.downcase <=> other.name.downcase)
  end

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
  
  def creations
    self.works + self.chapters + self.series
  end

  def replace_me_with_default
    self.creations.each {|creation| change_ownership(creation, self.user.default_pseud) }
    self.destroy
  end

  # Change the ownership of a creation from one pseud to another
  def change_ownership(creation, pseud)
    creation.pseuds.delete(self)
    creation.pseuds << pseud rescue nil
    if creation.is_a?(Work)
      creation.chapters.each {|chapter| self.change_ownership(chapter, pseud)}
      for series in creation.series
        if series.works.count > 1 && (series.works - [creation]).collect(&:pseuds).flatten.include?(self)
          series.pseuds << pseud rescue nil
        else
          self.change_ownership(series, pseud)
        end
      end
      comment_ids = creation.find_all_comments.collect(&:id).join(",")
      Comment.update_all("pseud_id = #{pseud.id}", "pseud_id = '#{self.id}' AND id IN (#{comment_ids})") unless comment_ids.blank?
    end
  end
    
end
