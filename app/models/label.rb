class Label < ActiveRecord::Base
  validates_length_of :name, :maximum => 42
  validates_format_of :name, 
                      :with => /\A[-a-zA-Z0-9 \/?.!''"";\|\]\[}{=~!@#\$%^&()_+]+\z/, 
                      :message => "tags can only be made up of letters, numbers, spaces and basic punctuation, but not commas and colons"

  def before_save
    self.name = name.strip.squeeze(" ")
  end

  # class methods
  def self.find_popular(args = {})
    find(:all, :select => 'labels.*, count(*) as popularity', 
      :limit => args[:limit] || 10,
      :joins => "JOIN taggings ON taggings.tag_id = labels.id",
      :conditions => args[:conditions],
      :group => "taggings.tag_id", 
      :order => "popularity DESC"  )
  end
  # example usage
  # Label.find_popular.each{|l| puts l.popularity + " " + l.name}

  # current official tag's : Fandoms, Characters, Ratings, Warnings
  # the set of official tags of each are those which are canonical
  def self.find_official(tag_name)
    tag = Label.find_by_name(tag_name)
    return false unless tag
    tags = tag.taggers
    tags.select{|tag| tag.is_canonical?}
  end
  # performance hog
  def self.find_freeform
    resemblers = Label.find_all_by_meta("resembles") || []
    others = Label.find_all_by_meta(nil) || []
    resemblers + others
  end

  def self.create_tags(tag_string, meta="nil")
     return false unless tag_string.is_a? String  # make sure you're working on a string
     tag_array = tag_string.split(ArchiveConfig.DELIMITER).map {|name| name.strip.squeeze(" ")}
     tag_array = tag_array - [""]  # remove any empty tags
     labels = []
     tag_array.each do |t|
       labels << Label.find_or_create_by_name(t)
     end
     case meta
       when 'fandoms', 'characters', 'warnings', 'ratings':
         labels.each { |l| l.tags << Label.find_by_name(meta) }
       when 'resembles':
        labels.each do |l|
          l.meta = 'resembles'
          l.save
          l.tags << labels - [l]
        end
     end
     return labels
  end
  # instance methods
  
  # current metas: banned, official, canonical, parent, resembles, ambiguous
 
  # "is" metas - defines the label as a 'kind' of tag
  [ 'banned', 'official', 'canonical' ].each do |kind|
    define_method("is_#{kind}?") { meta == kind }
  end
  def is_freeform?
     self.meta == nil || self.meta == 'resembles'
  end
  # official tags currently: Fandoms, Characters, Ratings, Warnings
  ['fandom', 'character', 'rating', 'warning' ].each do |kind|
    define_method("is_#{kind}?") { tags.include?(Label.find_by_name(kind.pluralize)) }
  end

  # "relationship" metas - shows the relationship of one label to another
  def child_of? (obj)
    true if obj.meta == 'parent' && self.tags.include?(obj)  
  end
  def resembles? (obj)
    true if obj.meta == 'resembles' && self.tags.include?(obj)  
  end
  def disambiguates? (obj)
    true if obj.meta == 'ambiguous' && self.tags.include?(obj)  
  end
  
  def resembles(obj)
    self.meta = 'resembles' unless self.meta
    self.save
    obj.meta = 'resembles' unless obj.meta
    obj.save
    self.tags << obj
    obj.tags << self
    obj.reload
  end

end
