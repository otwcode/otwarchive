class Fandom < Tag

  NAME = ArchiveConfig.FANDOM_CATEGORY_NAME
  
  def wrangle_merger(tag, update_works=true)
    super(tag, update_works)
    Tag.find_all_by_fandom_id(self.id).each {|t| t.update_attribute(:fandom_id, tag.id)}
  end

  def children
    ( Tag.find_all_by_fandom_id(self.id) + super ).uniq.compact.sort
  end
  
#   def parents
#     (super + [self.media] ).uniq.compact.sort
#   end

end

