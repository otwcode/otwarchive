# Database Change for issue 3127
# Set the default language to english (1,en)
# Updated 9/15/2013 - Stephanie
class SetDefaultImportLanguage < ActiveRecord::Migration
  def self.up
   change_column(:works, :language_id, :integer, :default => 1)
  end

  def self.down
    change_column(:works, :language_id, :integer, :default => nil)
  end

end

