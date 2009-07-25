class Pseud < ActiveRecord::Base

  NAME_LENGTH_MIN = 1
  NAME_LENGTH_MAX = 40
  DESCRIPTION_MAX = 500
  
  belongs_to :user
  has_many :bookmarks, :dependent => :destroy
  has_many :creatorships
  has_many :works, :through => :creatorships, :source => :creation, :source_type => 'Work'
  has_many :chapters, :through => :creatorships, :source => :creation, :source_type => 'Chapter'
  has_many :series, :through => :creatorships, :source => :creation, :source_type => 'Series'
  validates_presence_of :name
  validates_length_of :name, 
    :within => NAME_LENGTH_MIN..NAME_LENGTH_MAX, 
    :too_short => t('name_too_short', :default => "is too short (minimum is {{min}} characters)", :min => NAME_LENGTH_MIN),
    :too_long => t('name_too_long', :default => "is too long (maximum is {{max}} characters)", :max => NAME_LENGTH_MAX)
  validates_format_of :name, 
    :message => t('name_invalid_characters', :default => 'can contain letters, numbers, spaces, underscores, and dashes.'),
    :with => /\A[\w -]*\Z/    
  validates_format_of :name, 
    :message => t('name_no_letters_or_numbers', :default => 'must contain at least one letter or number.'),
    :with => /[a-zA-Z0-9]/
  validates_length_of :description, :allow_blank => true, :maximum => DESCRIPTION_MAX, 
    :too_long => t('description_too_long', :default => "must be less than {{max}} characters long.", :max => DESCRIPTION_MAX)
  
  after_update :check_default_pseud
  
  named_scope :on_works, lambda {|owned_works|
    {
      :select => "DISTINCT pseuds.*",
      :joins => :works,
      :conditions => {:works => {:id => owned_works.collect(&:id)}},
      :order => :name
    }
  }

  named_scope :alphabetical, :order => :name
  named_scope :starting_with, lambda {|letter| {:conditions => ['SUBSTR(name,1,1) = ?', letter]}}
  
  begin
   ActiveRecord::Base.connection
   ALPHABET = Pseud.find(:all, :select => :name).collect {|pseud| pseud.name[0,1].upcase}.uniq.sort
  rescue
    puts "no database yet, not initializing pseud alphabet"
    ALPHABET = ['A']
  end

  # Enigel Dec 12 08: added sort method
  # sorting by pseud name or by login name in case of equality
  def <=>(other)
    (self.name.downcase <=> other.name.downcase) == 0 ? (self.user_name.downcase <=> other.user_name.downcase) : (self.name.downcase <=> other.name.downcase)
  end
  
  # For use with the work and chapter forms
  def user_name
     self.user.login
  end
  
  def to_param
    name
  end

  # Gets the number of works by this user that the current user can see
  def visible_works_count
    self.works.select{|w| w.visible?(User.current_user)}.uniq.size
  end
  
  # Options can include :categories and :limit
  # Gets all the canonical tags used by a given pseud (limited to certain 
  # types if type options are provided), then sorts them according to 
  # the number of times this pseud has used them, then returns an array
  # of [tag, count] arrays, limited by size if a limit is provided 
  # FIXME: I'm also counting tags on works that aren't visible to the current user (drafts, restricted works)
  def most_popular_tags(options = {})
    if all_tags = Tag.by_pseud(self).by_type(options[:categories]).canonical
      tags_with_count = {}
      all_tags.uniq.each do |tag|
        tags_with_count[tag] = all_tags.find_all{|t| t == tag}.size
      end
      all_tags = tags_with_count.to_a.sort {|x,y| y.last <=> x.last }
      options[:limit].blank? ? all_tags : all_tags[0..(options[:limit]-1)]
    end
  end

  # Produces a byline that indicates the user's name if pseud is not unique
  def byline
    (name != user_name) ? name + " (" + user_name + ")" : name
  end
  
  def unposted_works
    @unposted_works = self.works.find(:all, :conditions => {:posted => false}, :order => 'works.created_at DESC')
  end
  
  # Takes a comma-separated list of bylines
  # Returns a hash containing an array of pseuds and an array of bylines that couldn't be found
  def self.parse_bylines(list)
    valid_pseuds, ambiguous_pseuds, failures = [], {}, []
    bylines = list.split ","
    for byline in bylines
      if byline.include? "("
        pseud_name, user_login = byline.split('(', 2)
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
  
  def check_default_pseud
    if !self.is_default? && self.user.pseuds.to_enum.find(&:is_default?) == nil
      default_pseud = self.user.pseuds.select{|ps| ps.name.downcase == self.user_name.downcase}.first
      default_pseud.update_attribute(:is_default, true)
    end
  end
    
end
