class CreateSavedWorks < ActiveRecord::Migration
  def change
    create_table :saved_works do |t|
      t.references :user, null: false
      t.references :work, null: false

      t.timestamps
    end
    add_index :saved_works, [:user_id, :work_id], unique: true
  end
end
