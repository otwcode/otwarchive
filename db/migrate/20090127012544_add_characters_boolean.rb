class AddCharactersBoolean < ActiveRecord::Migration
  def self.up
    add_column :tags, :has_characters, :boolean, :default => false, :null => false
    Tag.reset_column_information
    Pairing.all.each do |pairing|
      pairing.update_attribute(:has_characters, true) unless pairing.characters.blank?
    end
  end

  def self.down
  end
end
