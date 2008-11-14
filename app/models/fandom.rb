class Fandom < Tag

  NAME = ArchiveConfig.FANDOM_CATEGORY_NAME

  has_many :characters
  has_many :pairings
  has_many :freeforms

  def visible_works_count
    if User.current_user && User.current_user.kind_of?(Admin)
      conditions = {:posted => true}
    elsif User.current_user.is_a? User
      conditions = ['works.posted = ? AND (works.hidden_by_admin = ? OR users.id = ?)', true, false, User.current_user.id]
    else
      conditions = {:posted => true, :restricted => false, :hidden_by_admin => false}
    end
    self.works.count(:all,
        :conditions => conditions,
        :joins => "INNER JOIN creatorships ON (creatorships.creation_id = works.id AND creatorships.creation_type = 'Work')
                   INNER JOIN pseuds ON creatorships.pseud_id = pseuds.id
                   INNER JOIN users ON pseuds.user_id = users.id" )
  end
  
  def reassign_to_canonical
    super
    characters.each {|t| t.update_attribute(:fandom_id, synonym.id)}
    pairings.each {|t| t.update_attribute(:fandom_id, synonym.id)}
    freeforms.each {|t| t.update_attribute(:fandom_id, synonym.id)}
  end
  
  def media
    Media.find_by_id(self.media_id)
  end
  
  def unwrangled?
    return false if (self.canonical && self.media)
    return false if (!self.canonical && self.synonym)
    return false if self.banned
    return true
  end
end

