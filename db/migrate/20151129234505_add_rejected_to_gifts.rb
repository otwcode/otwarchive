class AddRejectedToGifts < ActiveRecord::Migration
  def change
    add_column :gifts, :rejected, :boolean, default: false, null: false
  end
end