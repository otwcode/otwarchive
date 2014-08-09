class FavoriteTag < ActiveRecord::Base
  belongs_to :user
  belongs_to :tag
  
  validates :user_id, presence: true
  validates :tag_id, presence: true
  
  def tag
    Tag.find_by_id(tag_id)
  end
  
  def tag_name
    tag = self.tag
    tag.name
  end

end
