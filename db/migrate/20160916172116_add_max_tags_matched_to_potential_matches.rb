class AddMaxTagsMatchedToPotentialMatches < ActiveRecord::Migration
  def change
    add_column :potential_matches, :max_tags_matched, :int
  end
end
