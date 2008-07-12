class CreateCountries < ActiveRecord::Migration
  def self.up
    create_table "countries", :force => true do |t|
      t.string "name",         :default => "", :null => false
    end
  end

  def self.down
    drop_table "countries"
  end
end