class SetTagging < ApplicationRecord
  belongs_to :tag
  belongs_to :tag_set, touch: true
  
  validates_uniqueness_of :tag_id, scope: [:tag_set_id], message: ts("^That tag already seems to be in this set.")
end
