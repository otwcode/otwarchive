class TagNomination < ActiveRecord::Base
  belongs_to :tag_set_nomination

  validates_presence_of :tagname
  validates_length_of :tagname, :minimum => 1, :message => "cannot be blank."
  validates_length_of :tagname,
    :maximum => ArchiveConfig.TAG_MAX,
    :message => "of tag is too long -- try using less than #{ArchiveConfig.TAG_MAX} characters."
  validates_format_of :tagname,
    :with => /\A[^,*<>^{}=`\\%]+\z/,
    :message => 'of a tag can not include the following restricted characters: , ^ * < > { } = ` \\ %'
  
  validate :type_validity
  def type_validity
    if (tag = Tag.find_by_name(tagname)) && tag.type != self.type
      errors.add(:base, ts("The tag %{tagname} is already in the archive as a #{tag.type} tag.", :tagname => self.tagname))
    end
  end


end
