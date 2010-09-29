class Pseud < ActiveRecord::Base
 
  has_attached_file :icon,
    :styles => { :standard => "100x100>" },
    :path => Rails.env.production? ? ":attachment/:id/:style.:extension" : ":rails_root/public:url",
    :storage => Rails.env.production? ? :s3 : :filesystem,
    :s3_credentials => "#{Rails.root}/config/s3.yml",
    :bucket => Rails.env.production? ? YAML.load_file("#{Rails.root}/config/s3.yml")['bucket'] : "",
    :default_url => "/images/user_icon.png"
   
  validates_attachment_content_type :icon, :content_type => /image\/\S+/, :allow_nil => true 
  validates_attachment_size :icon, :less_than => 500.kilobytes, :allow_nil => true 
 
  NAME_LENGTH_MIN = 1
  NAME_LENGTH_MAX = 40
  DESCRIPTION_MAX = 500
  
  belongs_to :user
  has_many :bookmarks, :dependent => :destroy
  has_many :recs, :class_name => 'Bookmark', :conditions => {:rec => true}
  has_many :comments  
  has_many :creatorships
  has_many :works, :through => :creatorships, :source => :creation, :source_type => 'Work'
  has_many :tags, :through => :works
  has_many :filters, :through => :works
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
  
  before_validation :clear_icon
  
  validates_presence_of :name
  validates_length_of :name, 
    :within => NAME_LENGTH_MIN..NAME_LENGTH_MAX, 
    :too_short => t('name_too_short', :default => "is too short (minimum is %{min} characters)", :min => NAME_LENGTH_MIN),
    :too_long => t('name_too_long', :default => "is too long (maximum is %{max} characters)", :max => NAME_LENGTH_MAX)
  validates_uniqueness_of :name, :scope => :user_id, :case_sensitive => false  
  validates_format_of :name, 
    :message => t('name_invalid_characters', :default => 'can contain letters, numbers, spaces, underscores, and dashes.'),
    :with => /\A[\w -]*\Z/    
  validates_format_of :name, 
    :message => t('name_no_letters_or_numbers', :default => 'must contain at least one letter or number.'),
    :with => /[a-zA-Z0-9]/
  validates_length_of :description, :allow_blank => true, :maximum => DESCRIPTION_MAX, 
    :too_long => t('description_too_long', :default => "must be less than %{max} characters long.", :max => DESCRIPTION_MAX)
  validates_length_of :icon_alt_text, :allow_blank => true, :maximum => ArchiveConfig.ICON_ALT_MAX,
    :too_long => t('icon_alt_too_long', :default => "must be less than %{max} characters long.", :max => ArchiveConfig.ICON_ALT_MAX)
  
  after_update :check_default_pseud
  
  scope :on_works, lambda {|owned_works|
    {
      :select => "DISTINCT pseuds.*",
      :joins => :works,
      :conditions => {:works => {:id => owned_works.collect(&:id)}},
      :order => :name
    }
  }
  
  scope :with_posted_works, {
    :select => "pseuds.*, count(pseuds.id) AS work_count",
    :joins => :works,
    :conditions => {:works => {:posted => true, :hidden_by_admin => false}},
    :group => 'pseuds.id',
    :order => :name
  }
  
  scope :with_public_works, {
    :select => "pseuds.*, count(pseuds.id) AS work_count",
    :joins => :works,
    :conditions => {:works => {:posted => true, :hidden_by_admin => false, :restricted => false}},
    :group => 'pseuds.id',
    :order => :name
  }

  scope :with_public_bookmarks, {
    :select => "pseuds.*, count(pseuds.id) AS bookmark_count",
    :joins => :bookmarks,
    :conditions => {:bookmarks => {:private => false, :hidden_by_admin => false}},
    :group => 'pseuds.id',
    :order => :name   
  }
  
  scope :with_public_recs, {
    :select => "pseuds.*, count(pseuds.id) AS rec_count",
    :joins => :bookmarks,
    :conditions => {:bookmarks => {:private => false, :hidden_by_admin => false, :rec => true}},
    :group => 'pseuds.id',
    :order => :name   
  }
  
  scope :alphabetical, :order => :name
  scope :starting_with, lambda {|letter| {:conditions => ['SUBSTR(name,1,1) = ?', letter]}}
  

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
    if User.current_user == :false
      self.works.posted.unhidden.unrestricted.count      
    else
      self.works.posted.unhidden.count
    end
  end

  # Gets the number of recs by this user
  def visible_recs_count
    self.recs.public.size
  end
  
  scope :public_work_count_for, lambda {|pseud_ids|
    {
      :select => "pseuds.id, count(pseuds.id) AS work_count",
      :joins => :works,
      :conditions => {:works => {:posted => true, :hidden_by_admin => false, :restricted => false}, :pseuds => {:id => pseud_ids}},
      :group => 'pseuds.id'
    }
  }  

  scope :posted_work_count_for, lambda {|pseud_ids|
    {
      :select => "pseuds.id, count(pseuds.id) AS work_count",
      :joins => :works,
      :conditions => {:works => {:posted => true, :hidden_by_admin => false}, :pseuds => {:id => pseud_ids}},
      :group => 'pseuds.id'
    }
  }

  scope :public_rec_count_for, lambda {|pseud_ids|
    {
      :select => "pseuds.id, count(pseuds.id) AS rec_count",
      :joins => :bookmarks,
      :conditions => {:bookmarks => {:private => false, :hidden_by_admin => false, :rec => true}, :pseuds => {:id => pseud_ids}},
      :group => 'pseuds.id'
    }
  }
  
  def self.rec_counts_for_pseuds(pseuds)
    if pseuds.blank?
      {}
    else
      pseuds_with_counts = Pseud.public_rec_count_for(pseuds.collect(&:id))
      count_hash = {}
      pseuds_with_counts.each {|p| count_hash[p.id] = p.rec_count.to_i}
      count_hash    
    end
  end
  
  def self.work_counts_for_pseuds(pseuds)
    if pseuds.blank?
      {}
    else    
      if User.current_user == :false
        pseuds_with_counts = Pseud.public_work_count_for(pseuds.collect(&:id))
      else
        pseuds_with_counts = Pseud.posted_work_count_for(pseuds.collect(&:id))
      end
      count_hash = {}
      pseuds_with_counts.each {|p| count_hash[p.id] = p.work_count.to_i}
      count_hash    
    end
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
  scope :by_byline, lambda {|byline|
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
    else
      pseud_name = byline.strip
      if options[:assume_matching_login]
        conditions = ['users.login = ? AND pseuds.name = ?', pseud_name, pseud_name]
      else
        conditions = ['pseuds.name = ?', pseud_name]
      end
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
    change_challenge_participation
    self.destroy
  end

  # Change the ownership of a creation from one pseud to another
  # Options: skip_series -- if you begin by changing ownership of the series, you don't
  # want to go back up again and get stuck in a loop
  def change_ownership(creation, pseud, options={})
    creation.pseuds.delete(self)
    creation.pseuds << pseud rescue nil
    if creation.is_a?(Work)
      creation.chapters.each {|chapter| self.change_ownership(chapter, pseud)}
      unless options[:skip_series]
        for series in creation.series
          if series.works.count > 1 && (series.works - [creation]).collect(&:pseuds).flatten.include?(self)
            series.pseuds << pseud rescue nil
          else
            self.change_ownership(series, pseud)
          end
        end
      end
      comment_ids = creation.find_all_comments.collect(&:id).join(",")
      Comment.update_all("pseud_id = #{pseud.id}", "pseud_id = '#{self.id}' AND id IN (#{comment_ids})") unless comment_ids.blank?
    elsif creation.is_a?(Series) && options[:skip_series]
      creation.works.each {|work| self.change_ownership(work, pseud)}    
    end
  end
  
  def change_membership(collection, new_pseud)
    self.collection_participants.in_collection(collection).each do |cparticipant| 
      cparticipant.pseud = new_pseud
      cparticipant.save
    end
  end
  
  def change_challenge_participation
    ChallengeSignup.update_all("pseud_id = #{self.user.default_pseud.id}", "pseud_id = #{self.id}")
    ChallengeAssignment.update_all("pinch_hitter_id = #{self.user.default_pseud.id}", "pinch_hitter_id = #{self.id}")
    return
  end
  
  def change_gift_recipients
    Gift.update_all("pseud_id = #{self.user.default_pseud.id}", "pseud_id = #{self.id}")
  end
  
  def change_bookmarks_ownership
    Bookmark.update_all("pseud_id = #{self.user.default_pseud.id}", "pseud_id = #{self.id}")
  end

  def change_collections_membership
    CollectionParticipant.update_all("pseud_id = #{self.user.default_pseud.id}", "pseud_id = #{self.id}")
  end
  
  def check_default_pseud
    if !self.is_default? && self.user.pseuds.to_enum.find(&:is_default?) == nil
      default_pseud = self.user.pseuds.select{|ps| ps.name.downcase == self.user_name.downcase}.first
      default_pseud.update_attribute(:is_default, true)
    end
  end
  
  # Delete current icon (thus reverting to archive default icon)
  def delete_icon=(value)
    @delete_icon = !value.to_i.zero?
  end
  
  def delete_icon
    !!@delete_icon
  end
  alias_method :delete_icon?, :delete_icon
  
  def clear_icon
    self.icon = nil if delete_icon? && !icon.dirty?
  end
    
  def self.search_with_sphinx(query, page)
    search_string, with_hash, query_errors = Query.split_query(query)
    # set pagination and extend mode
    options = {
      :per_page => ArchiveConfig.ITEMS_PER_PAGE, 
      :max_matches => ArchiveConfig.SEARCH_RESULTS_MAX, 
      :page => page, 
      :match_mode => :extended 
      }
    # attribute restrictions
    options[:with] = with_hash
    return query_errors, Pseud.search(search_string, options)
  end

  # Index for Thinking Sphinx
  define_index do

    # fields
    indexes :name
    indexes :description
    indexes :icon_alt_text

    # associations
    indexes user(:login), :as => 'user'
#    indexes works(:id), :as => 'work_id'
#    indexes tags(:name), :as => 'tag'

    # attributes
    has bookmarks(:id), :as => :bookmarks_ids
    has "COUNT(bookmarks.id)", :as => 'bookmark_count', :type => :integer

#    has creatorship.creation(:id), :as => :creation_ids
#    has "COUNT(works.id)", :as => 'work_count', :type => :integer

    # properties
    set_property :delta => :delayed
  end
  
end
