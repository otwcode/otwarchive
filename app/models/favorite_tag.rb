class FavoriteTag < ActiveRecord::Base
  belongs_to :user
  belongs_to :tag
  
  validates :user_id, presence: true
  validates :tag_id, presence: true
  validate :within_limit, on: :create
  
  def within_limit
    if self.user.favorite_tags(:reload).count >= ArchiveConfig.MAX_FAVORITE_TAGS
      errors.add(:base, ts('Sorry, you can only save %{maximum} favorite tags.', :maximum => ArchiveConfig.MAX_FAVORITE_TAGS))
    end
  end
  
  def tag
    Tag.find_by_id(tag_id)
  end
  
  def tag_name
    tag = self.tag
    tag.name
  end

end
