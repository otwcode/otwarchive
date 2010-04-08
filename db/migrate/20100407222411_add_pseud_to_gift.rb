class AddPseudToGift < ActiveRecord::Migration
  def self.up
    add_column :gifts, :pseud_id, :integer
  end

  def self.down
    remove_column :gifts, :pseud_id
  end
end
