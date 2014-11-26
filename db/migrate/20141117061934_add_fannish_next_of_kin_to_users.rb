class AddFannishNextOfKinToUsers < ActiveRecord::Migration
  def change
    add_column :users, :fannish_next_of_kin_user, :string
    add_column :users, :fannish_next_of_kin_email, :string
  end
end
