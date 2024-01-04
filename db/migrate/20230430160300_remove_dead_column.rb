class RemoveDeadColumn < ActiveRecord::Migration[6.0]
  def change
    remove_column :external_works, :dead, :boolean
  end
end
