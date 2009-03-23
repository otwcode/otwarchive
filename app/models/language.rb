class Language < Locale 
  has_many :works  
  acts_as_authorizable # so that each language can have authorized translators
  
  def to_param
    short
  end
  
  def work_count
    self.works.count(:conditions => {:posted => true})
  end
  
  def fandom_count
    Fandom.count(:joins => :works, :conditions => {:works => {:id => self.works.posted.collect(&:id)}}, :distinct => true, :select => 'tags.id')
  end
  
end