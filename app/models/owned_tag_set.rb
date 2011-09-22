class OwnedTagSet < ActiveRecord::Base
  # Rather than use STI or polymorphic associations, since really what we want to do here 
  # is build an extra layer of functionality on top of the generic tag set structure,
  # I've gone with creating a separate model and making it contain a generic tag set 
  # as a member. This way we don't have to duplicate the tag set code or functionality
  # and can just add on the extra stuff without cramming the tag set table full of empty
  # unused fields and having the controller have to sift out all the generic tag sets 
  # being used in prompts.
  # -- NN May 2011 
  
  belongs_to :tag_set, :dependent => :destroy
  accepts_nested_attributes_for :tag_set  
  
  has_many :tag_set_associations, :dependent => :destroy
  accepts_nested_attributes_for :tag_set_associations, :allow_destroy => true, 
    :reject_if => proc { |attrs| !attrs[:create_association] || attrs[:tag_id].blank? || (attrs[:parent_tag_id].blank? && attrs[:parent_tagname].blank?) }

  has_many :tag_set_nominations, :dependent => :destroy
  has_many :fandom_nominations, :through => :tag_set_nominations
  has_many :character_nominations, :through => :tag_set_nominations
  has_many :relationship_nominations, :through => :tag_set_nominations
  has_many :freeform_nominations, :through => :tag_set_nominations

  attr_protected :featured

  has_many :tag_set_ownerships, :dependent => :destroy
  has_many :moderators, :through => :tag_set_ownerships, :source => :pseud, :conditions => ['tag_set_ownerships.owner = ?', false]
  has_many :owners, :through => :tag_set_ownerships, :source => :pseud, :conditions => ['tag_set_ownerships.owner = ?', true]
  
  has_many :owned_set_taggings, :dependent => :destroy
  has_many :set_taggables, :through => :owned_set_taggings

  validates_presence_of :title, :message => ts("Please enter a title for your tag set.")
  validates_uniqueness_of :title, :case_sensitive => false, :message => ts('Sorry, that name is already taken. Try again, please!')
  validates_length_of :title,
    :minimum => ArchiveConfig.TITLE_MIN,
    :too_short=> ts("must be at least %{min} characters long.", :min => ArchiveConfig.TITLE_MIN)
  validates_length_of :title,
    :maximum => ArchiveConfig.TITLE_MAX,
    :too_long=> ts("must be less than %{max} characters long.", :max => ArchiveConfig.TITLE_MAX)
  validates_format_of :title,
    :with => /\A[^,*<>^{}=`\\%]+\z/,
    :message => 'of a tag set can not include the following restricted characters: , ^ * < > { } = ` \\ %'

  validates_length_of :description,
    :allow_blank => true,
    :maximum => ArchiveConfig.SUMMARY_MAX,
    :too_long => ts("must be less than %{max} characters long.", :max => ArchiveConfig.SUMMARY_MAX)

  validates_numericality_of :fandom_nomination_limit, :character_nomination_limit, :relationship_nomination_limit, :freeform_nomination_limit,
    :only_integer => true, :less_than_or_equal_to => 20, :greater_than_or_equal_to => 0,
    :message => ts('must be an integer between 0 and 20.')

  after_update :cleanup_outdated_associations
  def cleanup_outdated_associations
    tag_ids = SetTagging.where(:tag_set_id => self.tag_set.id)[:tag_id]
    TagSetAssociation.where(:owned_tag_set_id => self.id).where("tag_id NOT IN (?) OR parent_tag_id NOT IN (?)", tag_ids, tag_ids).delete_all
  end

  validate :no_midstream_nomination_changes
  def no_midstream_nomination_changes
    if !self.tag_set_nominations.empty? && 
      %w(fandom_nomination_limit character_nomination_limit relationship_nomination_limit freeform_nomination_limit).any? {|field| self.changed.include?(field)}
      errors.add(:base, ts("^You cannot make changes to nomination settings when nominations already exist. Please review and delete existing nominations first."))
    end
  end

  def self.owned_by(user = User.current_user)
    if user.is_a?(User)
      select("DISTINCT owned_tag_sets.*").
      joins("INNER JOIN tag_set_ownerships ON owned_tag_sets.id = tag_set_ownerships.owned_tag_set_id
             INNER JOIN pseuds ON tag_set_ownerships.pseud_id = pseuds.id
             INNER JOIN users ON pseuds.user_id = users.id").
      where("users.id = ?", user.id)
    end
  end

  def self.visible(user = User.current_user)
    if user.is_a?(User)
      select("DISTINCT owned_tag_sets.*").
      joins("INNER JOIN tag_set_ownerships ON owned_tag_sets.id = tag_set_ownerships.owned_tag_set_id
             INNER JOIN pseuds ON tag_set_ownerships.pseud_id = pseuds.id
             INNER JOIN users ON pseuds.user_id = users.id").
      where("owned_tag_sets.visible = true OR users.id = ?", user.id)
    else
      where("owned_tag_sets.visible = true")
    end
  end


  #### MODERATOR/OWNER

  def user_is_owner?(user)
    !(owners & user.pseuds).empty?
  end
  
  def user_is_moderator?(user)
    user_is_owner?(user) || !(moderators & user.pseuds).empty?
  end
  
  def add_owner(pseud)
    tag_set_ownerships.build({:pseud => pseud, :owner => true})
  end
  
  def add_moderator(pseud)    
    tag_set_ownerships.build({:pseud => pseud, :owner => false}) 
  end
  
  def owner_changes=(pseud_list)
    Pseud.parse_bylines(pseud_list)[:pseuds].each do |pseud|
      if self.owners.include?(pseud)
        self.owners -= [pseud] if self.owners.count > 1
      else
        self.moderators -= [pseud] if self.moderators.include?(pseud)
        add_owner(pseud)
      end
    end
  end
  
  def moderator_changes=(pseud_list)
    Pseud.parse_bylines(pseud_list)[:pseuds].each do |pseud|
      if self.moderators.include?(pseud)
        self.moderators -= [pseud]
      else
        add_moderator(pseud) unless self.owners.include?(pseud)
      end
    end
  end
  
  def owner_changes; nil; end
  def moderator_changes; nil; end

  ##### MANAGING NOMINATIONS
  
  # we can use redis to speed this up since tagset data is loaded there for autocomplete
  def already_in_set?(tagname)
    true unless $redis.zscore("autocomplete_tagset_#{tag_set.id}", tagname).nil?
  end

  # returns an array of arrays [id, name]
  def tags_in_set
    $redis.zrange("autocomplete_tagset_#{tag_set.id}", 0, -1).map {|redis_tag| Tag.parse_autocomplete_value(redis_tag)}
  end

  def already_nominated?(tagname)
    TagNomination.joins(:tag_set_nomination => :owned_tag_set).where("tag_set_nominations.owned_tag_set_id = ?", self.id).exists?(:tagname => tagname)
  end
  
  def already_rejected?(tagname)
    TagNomination.joins(:tag_set_nomination => :owned_tag_set).where("tag_set_nominations.owned_tag_set_id = ?", self.id).exists?(:tagname => tagname, :rejected => true)
  end

  def already_approved?(tagname)
    TagNomination.joins(:tag_set_nomination => :owned_tag_set).where("tag_set_nominations.owned_tag_set_id = ?", self.id).exists?(:tagname => tagname, :approved => true)
  end

  def clear_nominations!
    TagSetNomination.where(:owned_tag_set_id => self.id).delete_all
  end


  ##### MANAGING ASSOCIATIONS
  
  def load_batch_associations!(batch_associations, options = {})
    options.reverse_merge!({:do_relationships => false})
    association_lines = batch_associations.split("\n")
    association_lines.each do |line|
      children_names = line.split(',')
      parent_tag_id = Tag.where(:name => children.pop.strip).value_of :id
      next unless parent_tag_id
      children_names.each do |child|
        child_tag_id = Tag.where(:name => child.strip).value_of :id
        assoc = tag_set_associations.build(:tag_id => child_tag_id, :parent_tag_id => parent_tag_id)
        assoc.save
      end
    end
  end

    
end
