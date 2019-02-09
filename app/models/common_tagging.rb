# This class represents parent-child relationships between tags
# It should probably be renamed "ChildTagging" and have the flip tagging called "ParentTagging"?
# Also it doesn't need to be polymorphic -- in practice, all the types are Tag
# -- NN 11/2012
# Because I never understand without looking at one in the database: common_tag
# is the child tag and filterable is the parent tag.
# -- Sarken 01/2019
class CommonTagging < ApplicationRecord
  # we need "touch" here so that when a common tagging changes, the tag(s) themselves are updated and
  # they get noticed by the tag sweeper (which then updates their autocomplete data)
  belongs_to :common_tag, class_name: 'Tag', touch: true
  belongs_to :filterable, polymorphic: true, touch: true

  validates_presence_of :common_tag, :filterable
  validates_uniqueness_of :common_tag_id, scope: :filterable_id

  after_create :update_wrangler
  after_create :inherit_parents
  after_commit :update_search

  def update_wrangler
    unless User.current_user.nil?
      common_tag.update_attributes!(last_wrangler: User.current_user)
    end
  end

  # A relationship should inherit its characters' fandoms
  def inherit_parents
    if common_tag.is_a?(Relationship) && filterable.is_a?(Character)
      filterable.fandoms.each do |fandom|
        common_tag.add_association(fandom)
      end
    end
  end

  # If a tag's parent changes, reindex immediately to update unwrangled bins.
  def update_search
    common_tag.reindex_document
  end
end
