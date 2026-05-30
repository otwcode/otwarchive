class RemoveDeadColumn < ActiveRecord::Migration[6.0]
  uses_departure! if Rails.env.staging? || Rails.env.production?

  def change
    remove_column :external_works, :dead, :boolean
  end
end
