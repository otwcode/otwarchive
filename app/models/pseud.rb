class Pseud < ActiveRecord::Base
 
  has_attached_file :icon,
    :styles => { :standard => "100x100>" },
    :path => ENV['RAILS_ENV'] == 'production' ? ":attachment/:id/:style.:extension" : ":rails_root/public:url",
    :storage => ENV['RAILS_ENV'] == 'production' ? :s3 : :filesystem,
    :s3_credentials => "#{RAILS_ROOT}/config/s3.yml",
    :bucket => ENV['RAILS_ENV'] == 'production' ? YAML.load_file("#{RAILS_ROOT}/config/s3.yml")['bucket'] : "",
    :default_url => "/images/user_icon.png"
   
  validates_attachment_content_type :icon, :content_type => /image\/\S+/, :allow_nil => true 
  validates_attachment_size :icon, :less_than => 500.kilobytes, :allow_nil => true 
 
  NAME_LENGTH_MIN = 1
  NAME_LENGTH_MAX = 40
  DESCRIPTION_MAX = 500
  ICON_ALT_MAX = 50
  
  belongs_to :user
  has_many :bookmarks, :dependent => :destroy
  has_many :comments  
  has_many :creatorships
  has_many :works, :through => :creatorships, :source => :creation, :source_type => 'Work'
  has_many :chapters, :through => :creatorships, :source => :creation, :source_type => 'Chapter'
  has_many :series, :through => :creatorships, :source => :creation, :source_type => 'Series'
  has_many :collection_participants, :dependent => :destroy
  has_many :collections, :through => :collection_participants
  has_many :challenge_signups, :dependent => :destroy
  has_many :gifts
  
  has_many :offer_assignments, :through => :challenge_signups, :conditions => ["challenge_assignments.sent_at IS NOT NULL"]
  has_many :pinch_hit_assignments, :class_name => "ChallengeAssignment", :foreign_key => "pinch_hitter_id", 
    :conditions => ["challenge_assignments.sent_at IS NOT NULL"]


  has_many :prompts, :dependent => :destroy
  
  validates_presence_of :name
  validates_length_of :name, 
    :within => NAME_LENGTH_MIN..NAME_LENGTH_MAX, 
    :too_short => t('name_too_short', :default => "is too short (minimum is {{min}} characters)", :min => NAME_LENGTH_MIN),
    :too_long => t('name_too_long', :default => "is too long (maximum is {{max}} characters)", :max => NAME_LENGTH_MAX)
  validates_uniqueness_of :name, :scope => :user_id, :case_sensitive => false  
  validates_format_of :name, 
    :message => t('name_invalid_characters', :default => 'can contain letters, numbers, spaces, underscores, and dashes.'),
    :with => /\A[\w -]*\Z/    
  validates_format_of :name, 
    :message => t('name_no_letters_or_numbers', :default => 'must contain at least one letter or number.'),
    :with => /[a-zA-Z0-9]/
  validates_length_of :description, :allow_blank => true, :maximum => DESCRIPTION_MAX, 
    :too_long => t('description_too_long', :default => "must be less than {{max}} characters long.", :max => DESCRIPTION_MAX)
  validates_length_of :icon_alt_text, :allow_blank => true, :maximum => ICON_ALT_MAX,
    :too_long => t('icon_alt_too_long', :default => "must be less than {{max}} characters long.", :max => ICON_ALT_MAX)
  
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

  def unposted_works
    @unposted_works = self.works.find(:all, :conditions => {:posted => false}, :order => 'works.created_at DESC')
  end
  

  # look up by byline
  named_scope :by_byline, lambda {|byline|
    {
      :conditions => ['users.login = ? AND pseuds.name = ?', 
        (byline.include?('(') ? byline.split('(', 2)[1].strip.chop : byline),
        (byline.include?('(') ? byline.split('(', 2)[0].strip : byline)
      ],
      :include => :user
    }
  }

  # Produces a byline that indicates the user's name if pseud is not unique
  def byline
    (name != user_name) ? name + " (" + user_name + ")" : name
  end

  # Parse a string of the "pseud.name (user.login)" format into a pseud
  def self.parse_byline(byline, options = {})
    pseud_name = ""
    user_login = ""
    if byline.include?("(") 
      pseud_name, user_login = byline.split('(', 2)
      pseud_name = pseud_name.strip
      user_login = user_login.strip.chop
      conditions = ['users.login = ? AND pseuds.name = ?', user_login, pseud_name]
    elsif options[:assume_matching_login]
      pseud_name = byline.strip
      conditions = ['users.login = ? AND pseuds.name = ?', pseud_name, pseud_name]
    else
      conditions = ['pseuds.name = ?', pseud_name]
    end
    Pseud.find(:all, :include => :user, :conditions => conditions)
  end    
  
  # Takes a comma-separated list of bylines
  # Returns a hash containing an array of pseuds and an array of bylines that couldn't be found
  def self.parse_bylines(list, options = {})
    valid_pseuds, ambiguous_pseuds, failures = [], {}, []
    bylines = list.split ","
    for byline in bylines
      pseuds = Pseud.parse_byline(byline, options)
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
    Comment.update_all("pseud_id = #{self.user.default_pseud.id}", "pseud_id = #{self.id}") unless self.comments.blank?
    change_collections_membership
    change_gift_recipients
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
  
  def change_membership(collection, new_pseud)
    self.collection_participants.in_collection(collection).each do |cparticipant| 
      cparticipant.pseud = new_pseud
      cparticipant.save
    end
  end
  
  def change_gift_recipients
    Gift.update_all("pseud_id = #{self.user.default_pseud.id}", "pseud_id = #{self.id}") and return
  end
  
  def change_bookmarks_ownership
    Bookmark.update_all("pseud_id = #{self.user.default_pseud.id}", "pseud_id = #{self.id}") and return
  end

  def change_collections_membership
    CollectionParticipant.update_all("pseud_id = #{self.user.default_pseud.id}", "pseud_id = #{self.id}") and return
  end
  
  def check_default_pseud
    if !self.is_default? && self.user.pseuds.to_enum.find(&:is_default?) == nil
      default_pseud = self.user.pseuds.select{|ps| ps.name.downcase == self.user_name.downcase}.first
      default_pseud.update_attribute(:is_default, true)
    end
  end
    
end
