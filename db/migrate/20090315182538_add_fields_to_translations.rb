class AddFieldsToTranslations < ActiveRecord::Migration
  def self.up
    add_column :translations, :updated, :boolean, :default => false, :null => false
    add_column :translations, :betaed, :boolean, :default => false, :null => false
    add_column :translations, :translator_id, :integer
    add_column :translations, :beta_id, :integer    
  end

  def self.down
    remove_column :translations, :updated
    remove_column :translations, :betaed
    remove_column :translations, :translator_id
    remove_column :translations, :beta_id
  end
end
