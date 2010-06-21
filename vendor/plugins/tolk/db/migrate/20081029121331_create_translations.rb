class CreateTranslations < ActiveRecord::Migration
  def self.up
    create_table :translations do |t|
      t.references :phrase
      t.references :locale
      t.text :text

      t.timestamps
    end
  end

  def self.down
    drop_table :translations
  end
end
