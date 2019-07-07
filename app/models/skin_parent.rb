class SkinParent < ApplicationRecord
  include ActiveModel::ForbiddenAttributesProtection

  belongs_to :child_skin, class_name: "Skin", inverse_of: :skin_parents, touch: true
  belongs_to :parent_skin, class_name: "Skin", inverse_of: :skin_children

  validates :position,
    uniqueness: {scope: [:child_skin_id, :parent_skin_id], message: ts("^Position has to be unique for each parent.")},
    numericality: {only_integer: true, greater_than: 0}

  validates_presence_of :child_skin, :parent_skin

  validate :no_site_parent
  def no_site_parent
    if parent_skin.get_role == "site" && !%w(override site).include?(child_skin.get_role)
      errors.add(:base, ts("^You can't use %{title} as a parent unless replacing the default archive skin.", title: parent_skin.title))
    end
  end

  validate :no_circular_skin
  def no_circular_skin
    if parent_skin == child_skin
      errors.add(:base, ts("^You can't make a skin its own parent"))
    end
    parent_ids = SkinParent.get_all_parent_ids(self.child_skin_id)
    if parent_ids.include?(self.parent_skin_id)
      errors.add(:base, ts("^%{parent_title} is already a parent of %{child_title}", child_title: child_skin.title, parent_title: parent_skin.title))
    end

    child_ids = SkinParent.get_all_child_ids(self.child_skin_id)
    if child_ids.include?(self.parent_skin_id)
      errors.add(:base, ts("^%{parent_title} is a child of %{child_title}", child_title: child_skin.title, parent_title: parent_skin.title))
    end

    # also don't allow duplication

  end

  def self.get_all_parent_ids(skin_id)
    parent_ids = SkinParent.where(child_skin_id: skin_id).pluck(:parent_skin_id)
    ret = parent_ids
    parent_ids.each do |parent_id_val|
      ret += SkinParent.get_all_parent_ids(parent_id_val)
    end
    return ret
  end

  def self.get_all_child_ids(skin_id)
    child_ids = SkinParent.where(parent_skin_id: skin_id).pluck(:child_skin_id)
    ret = child_ids
    child_ids.each do |child_id_val|
      ret += SkinParent.get_all_child_ids(child_id_val)
    end
    return ret
  end

   def parent_skin_title
     self.parent_skin.try(:title) || ""
   end

   def parent_skin_title=(title)
     self.parent_skin = Skin.find_by(title: title)
   end

end
