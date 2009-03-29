class SplitLocalesAndLanguages < ActiveRecord::Migration
  def self.up
    create_table :languages, :force => true do |t|
      t.string :short, :limit => 4
      t.string :name
    end
    add_column :locales, :language_id, :integer, :null => false
    remove_column :locales, :short
    Work.update_all(["language_id = (?)", Language.default.id])
  end

  def self.down
    drop_table :languages
    remove_column :locales, :language_id
    add_column :locales, :short, :string, :limit => 4
  end
end
