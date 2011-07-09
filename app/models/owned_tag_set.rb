class OwnedTagSet < ActiveRecord::Base
  # Rather than use STI or polymorphic associations, since really what we want to do here 
  # is build an extra layer of functionality on top of the generic tag set structure,
  # I've gone with creating a separate model and making it contain a generic tag set 
  # as a member. This way we don't have to duplicate the tag set code or functionality
  # and can just add on the extra stuff without cramming the tag set table full of empty
  # unused fields and having the controller have to sift out all the generic tag sets 
  # being used in prompts.
  # -- NN May 2011 
  
  belongs_to :tag_set
  accepts_nested_attributes_for :tag_set  

  attr_protected :featured

  has_many :tag_set_ownerships, :dependent => :destroy
  has_many :moderators, :through => :tag_set_ownerships, :source => :pseud, :conditions => ['tag_set_ownerships.owner = ?', false]
  has_many :owners, :through => :tag_set_ownerships, :source => :pseud, :conditions => ['tag_set_ownerships.owner = ?', true]

  validates_presence_of :title, :message => ts("Please enter a title for your tag set.")
  validates_uniqueness_of :title, :case_sensitive => false, :message => ts('Sorry, that name is already taken. Try again, please!')
  validates_length_of :title,
    :minimum => ArchiveConfig.TITLE_MIN,
    :too_short=> ts("must be at least %{min} characters long.", :min => ArchiveConfig.TITLE_MIN)
  validates_length_of :title,
    :maximum => ArchiveConfig.TITLE_MAX,
    :too_long=> ts("must be less than %{max} characters long.", :max => ArchiveConfig.TITLE_MAX)

  validates_length_of :description,
    :allow_blank => true,
    :maximum => ArchiveConfig.SUMMARY_MAX,
    :too_long => ts("must be less than %{max} characters long.", :max => ArchiveConfig.SUMMARY_MAX)

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
  
  # We want to have all the matching methods defined on
  # TagSet available here, too, without rewriting them,
  # so we just pass them through method_missing
  def method_missing(method)
    super || (tag_set && tag_set.respond_to?(method) ? tag_set.send(method) : super)
  end

  def respond_to?(method, include_private = false)
    super || tag_set.respond_to?(method, include_private)
  end

  
end
