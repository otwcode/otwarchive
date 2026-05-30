class AddIndicesToOwnedSetTaggings < ActiveRecord::Migration[6.1]
  def change
    change_table :owned_set_taggings do |t|
      t.index :owned_tag_set_id
      t.index [:set_taggable_id, :set_taggable_type, :owned_tag_set_id],
              name: :index_owned_set_taggings_on_set_taggable_and_tag_set,
              unique: true
    end
  end
end
