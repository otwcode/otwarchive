class AddIndexToCommentsName < ActiveRecord::Migration[7.1]
  uses_departure! if Rails.env.staging? || Rails.env.production?

  def change
    add_index :comments, :name
  end
end
