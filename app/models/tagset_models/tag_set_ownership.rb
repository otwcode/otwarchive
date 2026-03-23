class TagSetOwnership < ApplicationRecord
  belongs_to :pseud
  belongs_to :owned_tag_set

  validates :pseud, uniqueness: { scope: :owned_tag_set_id }
end
