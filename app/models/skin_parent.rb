class SkinParent < ActiveRecord::Base
  belongs_to :child_skin, :class_name => "Skin"
  belongs_to :parent_skin, :class_name => "Skin"
  
  validates_uniqueness_of :position, :scope => [:child_skin_id, :parent_skin_id], :message => ts("has to be unique for each parent.")
  
  validate :no_site_parent
  def no_site_parent
    if parent_skin.role == "site" && !%w(override site).include?(child_skin.role)
      errors.add(:base, ts("^You can't add %{title} as a parent unless you make your skin an override skin.", :title => parent_skin.title))
    end
  end
end
