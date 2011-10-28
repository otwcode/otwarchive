class SkinParent < ActiveRecord::Base
  belongs_to :child_skin, :class_name => "Skin", :inverse_of => :skin_parents
  belongs_to :parent_skin, :class_name => "Skin", :inverse_of => :skin_children

  validates :position, 
    :uniqueness => {:scope => [:child_skin_id, :parent_skin_id], :message => ts("^Position has to be unique for each parent.")},
    :numericality => {:only_integer => true, :greater_than => 0}
    
  validates_presence_of :child_skin, :parent_skin
  
  validate :no_site_parent
  def no_site_parent
    if parent_skin.get_role == "site" && !%w(override site).include?(child_skin.get_role)
      errors.add(:base, ts("^You can't use %{title} as a parent unless replacing the default archive skin.", :title => parent_skin.title))
    end
  end
  
  validate :no_circular_skin
  def no_circular_skin
    if parent_skin == child_skin
      errors.add(:base, ts("^You can't make a skin its own parent!"))
    end
    if child_skin.parent_skins.value_of(:id).include?(parent_skin.id)
      errors.add(:base, ts("^%{parent_title} is already a parent of %{child_title}!", :child_title => child_skin.title, :parent_title => parent_skin.title))
    end
    if parent_skin.get_all_parents.include?(child_skin)
      errors.add(:base, ts("^%{child_title} is one of the ancestors of %{parent_title}!", :child_title => child_skin.title, :parent_title => parent_skin.title))
    end
    if child_skin.get_all_parents.include?(parent_skin)
      errors.add(:base, ts("^%{parent_title} is one of the ancestors of %{child_title}!", :child_title => child_skin.title, :parent_title => parent_skin.title))      
    end
  end
   
   def parent_skin_title
     self.parent_skin.try(:title) || ""
   end

   def parent_skin_title=(title)
     self.parent_skin = Skin.find_by_title(title)
   end
 
end
