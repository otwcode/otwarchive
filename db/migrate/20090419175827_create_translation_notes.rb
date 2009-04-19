class CreateTranslationNotes < ActiveRecord::Migration
  def self.up
    create_table :translation_notes do |t|
      t.text :note
      t.string :namespace
      t.references :user
      t.references :locale

      t.timestamps
    end
  end

  def self.down
    drop_table :translation_notes
  end
end
