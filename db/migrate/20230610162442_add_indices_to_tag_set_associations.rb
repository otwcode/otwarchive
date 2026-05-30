class AddIndicesToTagSetAssociations < ActiveRecord::Migration[6.1]
  uses_departure! if Rails.env.staging? || Rails.env.production?

  def change
    change_table :tag_set_associations do |t|
      t.index :tag_id
      t.index :parent_tag_id

      t.index [:owned_tag_set_id, :parent_tag_id, :tag_id],
              name: :index_tag_set_associations_on_tag_set_and_parent_and_tag,
              unique: true
    end
  end
end
